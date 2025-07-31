#!/bin/bash
IP=$(terraform -chdir=terraform output -raw instance_public_ip)

cat <<EOF > ../ansible/inventory.ini
[nifi]
$IP ansible_user=ubuntu ansible_ssh_private_key_file=__PLACEHOLDER__
EOF
