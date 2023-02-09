#!/bin/bash 
set -e

FAB_NETWORK_SCRIPT=./network.sh
chmod 777 $FAB_NETWORK_SCRIPT

$FAB_NETWORK_SCRIPT createChannel -c $1


