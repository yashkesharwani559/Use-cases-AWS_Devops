#!/bin/bash
AWS_ACCESS_KEY=$1
AWS_SECRET_KEY=$2

if [ -z "$AWS_ACCESS_KEY" ] || [ -z "$AWS_SECRET_KEY" ]; then
  echo "Usage: $0 <AWS_ACCESS_KEY> <AWS_SECRET_KEY>"
  exit 1
fi

echo "Starting full automation..."
cd terraform
terraform init
terraform apply -auto-approve   -var="aws_access_key=$AWS_ACCESS_KEY"   -var="aws_secret_key=$AWS_SECRET_KEY"

PUBLIC_IP=$(terraform output -raw public_ip)
PRIVATE_KEY=$(terraform output -raw private_key_path)

cd ../ansible
echo "[webserver]" > inventory.ini
echo "$PUBLIC_IP ansible_user=ec2-user ansible_ssh_private_key_file=$PRIVATE_KEY" >> inventory.ini

ansible-playbook -i inventory.ini webserver.yml

echo "Apache web server deployed successfully!"
echo "Access it at: http://$PUBLIC_IP"
