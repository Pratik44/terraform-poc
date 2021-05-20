variable "AMI" {
    type = "map"
    
    default =  {
        ap-south-1 = "ami-011a9944eb4abcf55"
        ap-south-2 = "ami-011a9944eb4abcf55"
    }
}


variable "AWS_REGION" {    
    default = "ap-south-1"
}

variable "public_sub_id" {
    value = ${module.subnet.public_sub_id}
}

#variable "private_sub_id" {
#type = "string"
#}
