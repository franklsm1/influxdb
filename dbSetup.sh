#!/bin/bash

INFLUX_HOST=$1
INFLUX_API_PORT=$2
DATABASE_NAME="${DATABASE_NAME:-default}"
WRITE_ID="{WRITE_ID:-writer}"
READ_ID="{READ_ID:-reader}"

RP_NAME="default"
RP_DURATION="30d"
RP_SHARD_DURATION="8h"

influx -host=${INFLUX_HOST} -port=${INFLUX_API_PORT} -execute="CREATE DATABASE $DATABASE_NAME"
echo "exit code $? from create database $DATABASE_NAME"

influx -host=${INFLUX_HOST} -port=${INFLUX_API_PORT} -execute="CREATE RETENTION POLICY \"$RP_NAME\" ON \"$DATABASE_NAME\" DURATION $RP_DURATION REPLICATION 1 SHARD DURATION $RP_SHARD_DURATION DEFAULT"

RESULT=$?
if [ $RESULT == 1 ]; then
    #If retention policy already exists (exit code of 1) then alter to use updated durations
    influx -host=${INFLUX_HOST} -port=${INFLUX_API_PORT} -execute="ALTER RETENTION POLICY \"$RP_NAME\" ON \"$DATABASE_NAME\" DURATION $RP_DURATION REPLICATION 1 SHARD DURATION $RP_SHARD_DURATION DEFAULT"
    echo "exit code $? from alter retention policy $RP_NAME"
else
    echo "exit code $RESULT from create retention policy $RP_NAME"
fi

# Create the write and read users with the proper privileges
bash ./createUser.sh $INFLUX_HOST $INFLUX_API_PORT $WRITE_ID $WRITE_PASSWORD
bash ./createUser.sh $INFLUX_HOST $INFLUX_API_PORT $READ_ID $READ_PASSWORD

# Give both users the specified privileges
influx -host=${INFLUX_HOST} -port=${INFLUX_API_PORT} -execute="GRANT ALL ON $DATABASE_NAME TO $WRITE_ID"
echo "exit code $? from grant all permissions to $WRITE_ID for the $DATABASE_NAME database"

influx -host=${INFLUX_HOST} -port=${INFLUX_API_PORT} -execute="GRANT READ ON $DATABASE_NAME TO $READ_ID"
echo "exit code $? from grant read permissions to $READ_ID for the $DATABASE_NAME database"
