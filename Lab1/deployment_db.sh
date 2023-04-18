#!/bin/bash

if [ $# -ne 3 ]; then
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

# sudo mysql -e "CREATE USER 'pc'@'%' IDENTIFIED BY 'pc';"
# sudo mysql -e "GRANT ALL ON *.* To 'pc'@'%' WITH GRANT OPTION;"

perl -0777 -i.original -pe 's/GRANT ALL PRIVILEGES ON petclinic.* TO pc\@localhost IDENTIFIED BY \x27pc\x27;/CREATE USER \x27pc\x27\@\x27localhost\x27 IDENTIFIED BY \x27pc\x27;\nGRANT ALL PRIVILEGES ON petclinic.* TO \x27pc\x27\@\x27localhost\x27;/igs' initDB.sql
cat ./initDB.sql | sudo mysql -f
cat ./populateDB.sql | sudo mysql -f

sudo mysql < ./initDB.sql
