#!/bin/bash
if [ "$1" = "init" ]; then

echo -e "Setting up remote bucket\n"

terraform -chdir=backend init
echo
echo -e "Creating S3 bucket\n"

terraform -chdir=backend apply -auto-approve

bucket_name=$(terraform -chdir=backend output -raw bucket_name)
region=$(terraform -chdir=backend output -raw region)

echo
echo -e "Updating backend\n"

cat <<EOF > backend.tf
terraform {
 backend "s3" {
   bucket         = "$bucket_name"
   key            = "app/terraform.tfstate"
   region         = "$region"
 }
}
EOF

terraform fmt -recursive >> /dev/null
echo
echo -e "Backend Configured\n"

echo -e "Setting up app infrastructure"

terraform init

terraform plan

echo
echo -e "You can now run terraform apply if the plan is in order!!!"
# Check if the destroy flag is provided
elif [ "$1" = "destroy" ]; then
  echo
  echo -e "Destroying resources\n"

  terraform destroy

  terraform -chdir=backend destroy

  rm -rf .terraform 0-backend.tf builds .terraform.lock.hcl backend/.terraform backend/terraform.tfstate* backend/.terraform.lock.hcl 

  echo
  echo -e "Cleanup completed"

else
echo -e "Invalid argument. Please use './init init' to setup resources or './init destroy' to clean up resources."
fi