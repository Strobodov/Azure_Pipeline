#!/bin/bash

####################################################################################
#DISCLAIMER
#Dit script is alleen geschikt voor test-omgevingen en niet voor productie! Er is geen rekening gehouden met diverse aspecten op gebied van beveiliging, redundantie of stabiliteit
####################################################################################

source ./Documents/passwords/passwords
az login -u $azure -p $azure_password
wait
az group create -n "mooiman" --location "westeurope"
wait
echo "De Resource Group staat klaar!"
az vm create -n "testVMscript" -g "mooiman" --admin-username $admin --generate-ssh-keys --image ubuntults --verbose --public-ip-address-dns-name mooiman-testvm --size Standard_D4_v3
wait
echo "De VM staat klaar!"
#log in op de VM en installeer alle CI-CD pakketten
ssh -i /home/mkornegoor/.ssh/id_rsa -l "$admin" "$fqdn" -o StrictHostKeyChecking=no <<EOF

#update de server 
sudo apt update && sudo apt upgrade --assume-yes --ignore-missing
wait
#installeer Docker
sudo apt-get install docker.io --assume-yes
wait
#installeer Virtualbox
sudo apt-get install virtualbox --assume-yes
wait
#installeer minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_1.3.1.deb \
 && sudo dpkg -i minikube_1.3.1.deb
wait
#stel virtualbox in als standaard host
minikube config set vm-driver virtualbox
#installeer kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
minikube start

#installeer Helm en start tevens Tiller
sudo snap install helm --classic
helm init --history-max 200
EOF
