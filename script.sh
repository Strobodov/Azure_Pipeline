#!/bin/bash

####################################################################################
#DISCLAIMER
#This script should only be used for testing and NOT for any kind of production environment. There has been no focus on any subject regarding security, redundancy or reliability!
####################################################################################

source config/variables
az login -u $azure -p $azure_password
wait
#define name of the resource group and Azure region you want to deploy in. (see Azure documentation for current list of options)
az group create -n "<<RESOURCE GROUP NAME>>" --location "<<AZURE REGION NAME"
wait
echo "Resource Group ready!"

#define what name you want to give the VM and DNS. Make sure these names are identical in the config/variables file!
az vm create -n "<<VM NAME>>" -g "<<RESOURCE GROUP NAME" --admin-username $admin --generate-ssh-keys --image ubuntults --verbose --public-ip-address-dns-name <<DNS NAME>> --size Standard_D4_v3
wait
echo "Virtual Server ready!"

#log into the server and install updates and various applications & packages
ssh -i <PATH TO SSH KEY> -l "$admin" "$fqdn" -o StrictHostKeyChecking=no <<EOF

#update server 
sudo apt update && sudo apt upgrade --assume-yes --ignore-missing
wait

#install Docker
sudo apt-get install docker.io --assume-yes
wait

#install Virtualbox
sudo apt-get install virtualbox --assume-yes
wait

#install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_1.3.1.deb \
 && sudo dpkg -i minikube_1.3.1.deb
wait

#set virtualbox as default virtual  host
minikube config set vm-driver virtualbox

#install kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
minikube start

#install Helm and start Tiller
sudo snap install helm --classic
helm init --history-max 200
EOF
