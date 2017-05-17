#!/bin/bash
set -e

az login --service-principal -u $service_principal_id -p $service_principal_secret --tenant $tenant_id
az account set --subscription "$subscription_id"  &> /dev/null
#Create th eRG is it does not exist
az group create --name "$rg_name" --location "$rg_location"

#Check for existing RG
az group show $rg_name 1> /dev/null

if [ $? != 0 ]; then
	echo "Resource group with name" $rg_name "could not be found. Creating new resource group.."
	set -e
	(
		set -x
		az group create --name $rg_name --location $rg_location 1> /dev/null
	)
	else
	echo "Using existing resource group..."
fi

#Start deployment
echo "Starting deployment..."
(
	set -x
	az group deployment create --name web-nodejs  -g $rg_name --template-file web-nodejs/arm/appservice-template.json \
             --parameters "{\"storageAccountType\":{\"value\":\"Standard_GRS\"}}" --verbose
)

if [ $?  == 0 ]; 
 then
	echo "Template has been successfully deployed"
fi

#Create  a deployment credential is it does not exist

az appservice web deployment user set --user-name $deployment_username --password $deployment_password



