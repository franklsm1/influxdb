# influxdb
Create an Influxdb database with authentication enabled that takes in encrypted passwords

## Configuration
Variable | Description | Default value | Sample value 
-------- | ----------- | ------------- | ------------
DATABASE_NAME | name of database to create | default | 
INFLUX_ADMIN_ID | admin user | admin |
INFLUX_ADMIN_PASSWORD | 256-bit openssl encrypted password | | 537Gm6HZpoNOjF/LJrwDfQ==
WRITE_ID | name of write user for DB | writer |
WRITE_PASSWORD | 256-bit openssl encrypted password | | 537Gm6HZpoNOjF/LJrwDfQ==
READ_ID | name of read user for DB | reader |
READ_PASSWORD | 256-bit openssl encrypted password | | 537Gm6HZpoNOjF/LJrwDfQ==
STANDARD_CRYPT__IV | 256-bit openssl initialization vector | | hex encoded 32 charachters
STANDARD_CRYPT__KEY | 256-bit openssl key | | hex encoded 64 charachters

## Using openssl
General info about openssl:
https://wiki.openssl.org/index.php/Enc#Use_a_given_Key

How to generate a key and IV see:
http://www.ibm.com/support/knowledgecenter/en/SSLVY3_9.7.0/com.ibm.einstall.doc/topics/t_einstall_GenerateAESkey.html

To encode a password with openssl:
```
PASSWORD_ENCODED="$(printf "$1\n" \
| openssl enc -p -K $STANDARD_CRYPT__KEY -iv $STANDARD_CRYPT__IV -aes-128-cbc -base64 \
| sed -e '$!d')"

echo $PASSWORD_ENCODED
```

To decode an encrypted password:
```
PASSWORD_DECODED="$(printf "$1\n" \
| openssl enc -p -d -K $STANDARD_CRYPT__KEY -iv $STANDARD_CRYPT__IV -aes-128-cbc -base64 \
| sed -e '$!d')"

echo $PASSWORD_DECODED
```
