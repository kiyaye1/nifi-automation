#!/bin/bash
set -e
IP=$(terraform -chdir=terraform output -raw instance_public_ip)
mkdir -p terraform/ansible
cat <<EOF > terraform/ansible/inventory.ini
[nifi]
$IP ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/nifi.pem
EOF
