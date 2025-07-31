#!/bin/bash
set -e

IP=$(terraform -chdir=terraform output -raw instance_public_ip)

# Create ansible dir relative to this script
mkdir -p ./ansible

# Write inventory to local ansible folder
echo "[nifi]" > ./ansible/inventory.ini
echo "$IP ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/nifi.pem" >> ./ansible/inventory.ini


