

#module "vpc" {
#   source = "/Users/apple/Desktop/Terraform/terraform-poc/lib.aws.vpc/"
#}




resource "aws_subnet" "public_sub" {
    vpc_id = "${var.vpc_id}"
    cidr_block = "10.0.1.0/24"
    tags = {
        Name = "Public-subnet"
    }
}

resource "aws_subnet" "private_sub" {
    vpc_id = "${var.vpc_id}"
    cidr_block = "10.0.2.0/24"
    tags = {
        Name = "Private-subnet"
    }
}

