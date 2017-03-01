FROM influxdb:1.1.0

WORKDIR /opt/ibm/app
COPY . /opt/ibm/app

CMD ["bash", "initInflux.sh"]
