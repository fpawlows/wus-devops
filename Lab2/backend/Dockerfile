FROM maven

RUN apt update -y
RUN apt upgrade -y

RUN git clone https://github.com/spring-petclinic/spring-petclinic-rest.git
WORKDIR /spring-petclinic-rest

RUN mvn package

ARG BACKEND_PORT=4013
ENV SPRING_PROFILES_ACTIVE="mysql,spring-data-jpa"
ENV SERVER_PORT=$BACKEND_PORT

ENTRYPOINT \
    SPRING_DATASOURCE_URL="jdbc:mysql://${DB_ADDRESS}:${DB_PORT}/petclinic?useUnicode=true" \
    mvn spring-boot:run
