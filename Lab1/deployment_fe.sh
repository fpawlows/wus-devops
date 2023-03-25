sudo apt-get update
sudo apt-get upgrade -y

curl -sL https://deb.nodesource.com/setup_16.x | sudo bash -
sudo apt install git -y
sudo apt install curl -y
sudo apt install nodejs -y
sudo apt install nginx -y
# sudo apt install npm -y # why not????

# ...why??? https://github.com/nvm-sh/nvm/issues/2432
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion" # This loads nvm bash_completion

nvm install 16
git clone https://github.com/spring-petclinic/spring-petclinic-angular
cd spring-petclinic-angular

npm install 
npm install -g angular-http-server
npm run build -- --prod
npx angular-http-server --path ./dist # TODO add port once we have VMs set up
