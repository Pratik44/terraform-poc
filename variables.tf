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

#variable "vpc_id" {
#    type = string
#}
