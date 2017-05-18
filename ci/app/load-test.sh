#!/bin/bash
set -e

ab -n 100 -c 10 "http://${webapp_name}.azurewebsites.net"
