#!/bin/bash
# $1 = influx host, $2 = influx api port, $3 = user id, $4 = ssl encoded password, $5 = admin privileges

# Decode the encoded password
PASSWORD_DECODED="$(printf "$4\n" \
    | openssl enc -p -d -K $STANDARD_CRYPT__KEY -iv $STANDARD_CRYPT__IV -aes-256-cbc -base64 \
    | sed -e '$!d')"

# Create user with the provided username, password, and privileges.
influx -host=$1 -port=$2 \
 -execute="CREATE USER $3 WITH PASSWORD '$PASSWORD_DECODED' $5"

RESULT=$?
if [ $RESULT == 1 ]; then
    #If user already exists, but has a different password (exit code of 1) then update the password
    influx -host=$1 -port=$2 \
    -execute="SET PASSWORD FOR $3 = '$PASSWORD_DECODED'"
    echo "exit code $? from update $3's password"
else
    echo "exit code $RESULT from create user $3"
fi
