#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Correct usage: $0 DATABASE_USER DATABASE_PASSWORD "
    exit 1
fi

sudo apt-get update
sudo apt-get upgrade -y


INIT_DB="https://raw.githubusercontent.com/spring-petclinic/spring-petclinic-rest/master/src/main/resources/db/mysql/initDB.sql"
POPULATE_DB="https://raw.githubusercontent.com/spring-petclinic/spring-petclinic-rest/master/src/main/resources/db/mysql/populateDB.sql"

sudo apt-get install mysql-server -y
sudo systemctl enable --now mysql

wget $INIT_DB
wget $POPULATE_DB

sudo mysql -e "CREATE USER 'root_db'@'%' IDENTIFIED BY 'root_db';"
sudo mysql -e "GRANT ALL ON *.* To 'root_db'@'%' WITH GRANT OPTION;"
cat ./initDB.sql | sudo mysql -f
cat ./populateDB.sql | sudo mysql -f

sudo mysql < ./initDB.sql
