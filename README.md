# terraform-poc
# This is for Terrafomr POC
# Trying to create VPC, subnets(public, private), NSG(80,443), webserver(datadisk), Loadbalancer, Disk encryption, AutoscalingGroup(with disk )


Following steps to deploy the above mentioned resources on AWS cloud.
Pre-requisite:
1.) Following tools to be installed locally  " aws cli ", " git ", " terraform " 
2.) Configure ssh-key based authentication with github account.

# terraform installation
# https://learn.hashicorp.com/tutorials/terraform/install-cli
# Download specific version  
https://www.terraform.io/downloads.html

# Installing git
# https://git-scm.com/download/win

# Install aws clii
# https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-windows.html

Steps: 
1.) Login to AWS account
# aws configure
2.) Clone the repo 
# clone the repo : git clone git@github.com:Pratik44/terraform-poc.git

3.) Change current working directory to "terraform-poc"
# cd terraform-poc

4.) Initialize terraform (this downloads and installs all the modules you are calling inside your .tf files)
# terraform init

5.) Validate your terraform configuration
# terraform validate

6.) Run terraform plan to view and verify resources going to be deployed.
# terraform plan
6.5) Correct if any errors

7.) Now run apply command
# terraform apply --auto-approve 
