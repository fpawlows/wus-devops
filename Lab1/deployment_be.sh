sudo apt-get update
sudo apt-get upgrade -y

sudo apt install git -y
sudo apt install openjdk-17-jdk openjdk-17-jre -y

git clone https://github.com/spring-petclinic/spring-petclinic-rest.git
cd spring-petclinic-rest

SPRING_PROP="./spring-petclinic-rest/src/main/resources/application.properties"



sed -i "s/spring.profiles.active=hsqldb/spring.profiles.active=mysql/g" $SPRING_PROP

./mvnw spring-boot:run
