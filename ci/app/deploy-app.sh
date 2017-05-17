#!/bin/bash
set -e

az login --service-principal -u $service_principal_id -p $service_principal_secret --tenant $tenant_id
az account set --subscription "$subscription_id"  &> /dev/null

uuid=$(cat /proc/sys/kernel/random/uuid)

echo "uuid=${uuid}"

az appservice web deployment user set --user-name $uuid --password $deployment_password

#Configure local GIT deployment
git_url=$(az appservice web source-control config-local-git --name $webapp_name --resource-group $rg_name --query url --output tsv)

echo $git_url

#Add the Password in the URL
result_string="${git_url/$uuid/$uuid:$deployment_password}"

echo $result_string

cd web-nodejs
git remote add azure $result_string
git push azure master --force


