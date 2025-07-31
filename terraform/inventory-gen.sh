#!/bin/bash
set -e

IP=$(terraform -chdir=terraform output -raw instance_public_ip)

# Ensure ansible directory exists
mkdir -p ../ansible

# Write inventory
echo "[nifi]" > ../ansible/inventory.ini
echo "$IP ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/nifi.pem" >> ../ansible/inventory.ini

