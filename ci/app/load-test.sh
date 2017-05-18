#!/bin/bash
set -e
echo "web app name = ${webapp_name}"
ab -n 100 -c 10 "http://${webapp_name}.azurewebsites.net/"
