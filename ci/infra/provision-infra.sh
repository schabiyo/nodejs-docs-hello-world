#!/bin/bash
#set -e
set +e

az login --service-principal -u $service_principal_id -p $service_principal_secret --tenant $tenant_id
az account set --subscription "$subscription_id"  &> /dev/null
#Create th eRG is it does not exist
#Check for existing RG

set -x
az group create --name $rg_name --location $rg_location 1> /dev/null

set +e

#Let validate the deployment template first
echo "Validating the template...."
(
az group deployment validate \
    --resource-group $rg_name \
    --template-file web-nodejs/ci/infra/arm/appservice-template.json \
    --parameters "{\"siteName\":{\"value\":\"$webapp_name\"}, \"hostingPlanName\":{\"value\":\"$webapp_name\"}}"
)

#Start deployment
echo "Starting deployment..."
(
	set -x
	az group deployment create --name web-nodejs  -g $rg_name --template-file web-nodejs/ci/infra/arm/appservice-template.json \
             --parameters "{\"siteName\":{\"value\":\"$webapp_name\"}, \"hostingPlanName\":{\"value\":\"$webapp_name\"}}" --verbose
)

if [ $?  == 0 ]; 
 then
	echo "Template has been successfully deployed"
fi

#Create  a deployment credential is it does not exist

#az appservice web deployment user set --user-name $deployment_username --password $deployment_password

#Configure local GIT deployment
#git_url=$(az appservice web source-control config-local-git --name $webapp_name --resource-group $rg_name --query url --output tsv)

#echo $git_url


