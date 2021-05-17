terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

#resource "aws_vpc" "vpc" {
#  cidr_block       = "10.0.0.0/16"
#  instance_tenancy = "default"
#}

module "vpc" {
   source = "/Users/apple/Desktop/Terraform/terraform-poc/lib.aws.vpc/"
}



module "subnet" {
    source = "/Users/apple/Desktop/Terraform/terraform-poc/lib.aws.subnet/"
    vpc_id = "${module.vpc.vpc_id}"
}

#resource "aws_subnet" "public_sub" {
#    vpc_id = "${module.vpc.vpc_id}"
#    cidr_block = "10.0.1.0/24"
#    tags = {
#        Name = "Public-subnet"
#    }
#}

#resource "aws_subnet" "private_sub" {
#    vpc_id = "${module.vpc.vpc_id}"
#    cidr_block = "10.0.2.0/24"
#    tags = {
#        Name = "Private-subnet"
#    }
#}


resource "aws_internet_gateway" "poc-igw" {
    vpc_id = "${module.vpc.vpc_id}"
    tags = {
        Name = "poc-igw"
    }
}

resource "aws_route_table" "poc-public-crt" {
    vpc_id = "${module.vpc.vpc_id}"
    
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0" 
        //CRT uses this IGW to reach internet
        gateway_id = "${aws_internet_gateway.poc-igw.id}" 
    }
    
    tags = {
        Name = "poc-public-crt"
    }
}

resource "aws_route_table_association" "poc-crta-public-subnet"{
    subnet_id = "${module.subnet.public_sub_id}"
    route_table_id = "${aws_route_table.poc-public-crt.id}"
}




resource "aws_security_group" "web-allowed" {
    vpc_id = "${module.vpc.vpc_id}"
    
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "web-traffic-allowed"
    }
}












#variable "AMI" {
#    type = "map"
#    
#    default = {
#        ap-south-1 = "ami-011a9944eb4abcf55"
#        ap-south-2 = "ami-011a9944eb4abcf55"
#    }
#}


resource "aws_instance" "webserver" {
    ami = "${lookup(var.AMI, var.AWS_REGION)}"
    instance_type = "t2.micro"
    # VPC
    subnet_id = "${module.subnet.public_sub_id}"
    # Security Group
    vpc_security_group_ids = ["${aws_security_group.web-allowed.id}"]
  tags = {
    Name = "POCWebserver"
  }
}



