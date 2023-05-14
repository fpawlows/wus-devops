FROM mysql:5.7.42-debian
ENV MYSQL_ROOT_PASSWORD=petclinic
ENV MYSQL_USER=pc
ENV MYSQL_PASSWORD=petclinic
ENV MYSQL_DATABASE=petclinic

ARG MYSQL_PORT=4003
ENV MYSQL_TCP_PORT=$MYSQL_PORT

# Download service database initial files
RUN apt-get update && apt-get upgrade -y \
&& apt-get install wget -y \
&& mkdir /docker-entrypoint-initdb.d -p \
&& cd /docker-entrypoint-initdb.d \
&& wget "https://raw.githubusercontent.com/spring-petclinic/spring-petclinic-rest/master/src/main/resources/db/mysql/initDB.sql" \
&& wget "https://raw.githubusercontent.com/spring-petclinic/spring-petclinic-rest/master/src/main/resources/db/mysql/populateDB.sql" \
&& cd -
