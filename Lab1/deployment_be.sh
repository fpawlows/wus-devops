#!/bin/bash
#TODO rewrite

set -euxo pipefail

if [ $# -lt 2 ]; then
  echo 1>&2 "$0: not enough arguments"
  echo 1>&2 "Usage: $0 PORT DATABASE_ADDRESS DATABASE_PORT DATABASE_USER DATABASE_PASSWORD"
  exit 2 
fi

PORT=$1
DATABASE_ADDRESS=$2
DATABASE_PORT=$3
DATABASE_USER=$4
DATABASE_PASSWORD=$5

sudo apt-get update
sudo apt-get upgrade -y

sudo apt install git -y
sudo apt install openjdk-17-jdk openjdk-17-jre -y

git clone https://github.com/spring-petclinic/spring-petclinic-rest.git

SPRING_PROP="./spring-petclinic-rest/src/main/resources/application.properties"
MYSQL_PROP="./spring-petclinic-rest/src/main/resources/application-mysql.properties"

sed -i "s/spring.profiles.active=hsqldb/spring.profiles.active=mysql/g" $SPRING_PROP
sed -i "s/server.port=9966/server.port=$PORT/g" $SPRING_PROP

sed -i "s/localhost:3306/$DATABASE_ADDRESS:$DATABASE_PORT/g" $MYSQL_PROP
sed -i "s/spring.datasource.username=pc/spring.datasource.username=$DATABASE_USER/g" $MYSQL_PROP
sed -i "s/spring.datasource.password=petclinic/spring.datasource.password=$DATABASE_PASSWORD/g" $MYSQL_PROP

cat $MYSQL_PROP >> $SPRING_PROP

cd spring-petclinic-rest
./mvnw spring-boot:run
