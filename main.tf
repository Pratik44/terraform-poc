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
#   source = "/Users/apple/Desktop/Terraform/terraform-poc/lib.aws.vpc/"
    source = "git::git@github.com:Pratik44/lib.aws.vpc"        
}



module "subnet" {
#    source = "/Users/apple/Desktop/Terraform/terraform-poc/lib.aws.subnet/"
    source = "git::git@github.com:Pratik44/lib.aws.subnet" 
#    vpc_id = "${module.vpc.vpc_id}"
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

resource "aws_volume_attachment" "sec_disk_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.secondary_disk.id
  instance_id = aws_instance.webserver.id
}

resource "aws_ebs_volume" "secondary_disk" {
  availability_zone = "ap-south-1"
  size              = 1
}


resource "aws_elb" "web_elb" {
  name = "web-elb"
  security_groups = [
    aws_security_group.web-allowed.id
  ]
  subnets = [ "${module.subnet.public_sub_id}" ]

  cross_zone_load_balancing   = true

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:80/"
  }

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "80"
    instance_protocol = "http"
  }

}


resource "aws_autoscaling_group" "web" {
  name = "${aws_instance.webserver.tags.Name}-asg"

  min_size             = 1
  desired_capacity     = 2
  max_size             = 4
  
  health_check_type    = "ELB"
  load_balancers = [
    aws_elb.web_elb.id
  ]

  launch_configuration = aws_instance.webserver.tags.Name

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

  vpc_zone_identifier  = [
    "${module.subnet.public_sub_id}"
  ]

  # Required to redeploy without an outage.
  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "web"
    propagate_at_launch = true
  }

}

output "elb_dns_name" {
  value = aws_elb.web_elb.dns_name
}
