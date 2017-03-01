#!/bin/bash

# Start influx to operate on it.
exec influxd &

INFLUX_HOST=localhost
INFLUX_API_PORT=8086
INFLUX_ADMIN_ID="${INFLUX_ADMIN_ID:-admin}"
STATUS=$(curl -slI -w "%{http_code}" "http://${INFLUX_HOST}:${INFLUX_API_PORT}/ping" -o /dev/null)

# Wait for influx to start up before starting our work
i=0
while [ "$STATUS" != "204" ] && [ $i -lt 50 ] 
do
  sleep 3
  i=$((i+1))
  STATUS=$(curl -slI -w "%{http_code}" "http://${INFLUX_HOST}:${INFLUX_API_PORT}/ping" -o /dev/null)
done

if [ "$STATUS" = "204" ]; then
    # Enable authentication
	export INFLUXDB_HTTP_AUTH_ENABLED=true

	# Create an admin user
	bash ./createUser.sh $INFLUX_HOST $INFLUX_API_PORT $INFLUX_ADMIN_ID $INFLUX_ADMIN_PASSWORD "WITH ALL PRIVILEGES"

	# Create database and users with proper privileges
	bash ./dbSetup.sh $INFLUX_HOST $INFLUX_API_PORT
else
  echo "Could not reach influxd"
fi

# Restart influx for auth enablement to take effect
kill -s TERM %1
influxd
