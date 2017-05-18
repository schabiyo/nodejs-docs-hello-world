#!/bin/bash
set -e

az login --service-principal -u $service_principal_id -p $service_principal_secret --tenant $tenant_id
az account set --subscription "$subscription_id"  &> /dev/null

uuid=$(cat /proc/sys/kernel/random/uuid)

echo "uuid=${uuid}"

#Get the FTP information

profiles=$(az appservice web deployment list-publishing-profiles -g $rg_name --name $webapp_name)

echo $profiles

username=$(jq .[1].userName <<< $profiles)
password=$(jq .[1].userPWD <<< $profiles)
ftpURL=$(jq .[1].publishUrl <<< $profiles)


echo "FTPURL=${ftpURL}"
echo "Username=${username}"
echo "Pwd=${password}"


TRIMMED_RESULT="${password%\"}"
password="${TRIMMED_RESULT#\"}"

TRIMMED_RESULT="${username%\"}"
username="${TRIMMED_RESULT#\"}"

TRIMMED_RESULT="${ftpURL%\"}"
ftpURL="${TRIMMED_RESULT#\"}"


echo "FTPURL=${ftpURL}"
echo "Username=${username}"
echo "Pwd=${password}"

IFS='$' read -r -a array <<< $username
$username="${array[1]}"

echo "username=${$username}"

cd web-nodejs

lftp -d -u $username,$password $ftpURL  << END_SCRIPT
mirror -R . --exclude .git --exclude ci/
exit
END_SCRIPT


