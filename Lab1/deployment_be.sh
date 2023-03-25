sudo apt-get update
sudo apt-get upgrade -y

sudo apt install git
apt install openjdk-17-jdk openjdk-17-jre

git clone https://github.com/spring-petclinic/spring-petclinic-rest.git
cd spring-petclinic-rest
./mvnw spring-boot:run