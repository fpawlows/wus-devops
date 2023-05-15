# Prerequisites
In order to get all neccessary modules, simply run
```sh
sudo ./init_master.sh
```
on your local machine

# Building infrastructure
Before we start, it's necessary to generate new pair of rsa keys.
```
ssh-keygen -f Lab2.pem
```
Copy the path to both of the keys and paste the path to public key in `Create a virtual machine` task inside `main.yml` file under `key_data` parameter. Then paste the path to private key into `./inventories/inventory1.yml` under `ansible_ssh_private_key_file` parameter (3 times).

You can now build every component required for this exercise by running
```sh
ansible-playbook ./main.yml
```
This will create
* resource group (with a name specified in vars section)
* virtual network (with a name [resource group name]Vnet)
* 3 public IP addresses (with WUT Azure subscription it's impossible to create more than 3, so you cannot run the playbook on azure VM; their names are: [deployment name]IP)
* 3 network security groups (their names are: [deployment name]NSG)
* 3 subnets (their names are: [deployment name]NSG)
* 3 network interfaces (their names are: [deployment name]NIC)
* 3 virtual machines (their names are: [deployment name]VM)

At the end, 3 public IPs will be printed out to the console. They are needed for the next step

# Deployment
In order to deploy to newly created VMs it is required to copy and paste recently printed public IPs into their corresponding hosts in `./inventories/inventory1.yml`
Finally you can perform
```sh
ansible-playbook ./deploy.yml -i ./inventories/inventory1.yml
```

# Cleanup
In order to start over you can use 
```sh
ansible-playbook cleanup.yml --extra-vars "name=WUSLab2ResourceGroup"
```
Note: replace WUSLab2ResourceGroup with the name of your resource group if you already changed it