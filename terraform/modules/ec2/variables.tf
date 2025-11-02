variable "ami" {
  type = string
  description = "AMI ID to use for the instance"
}

variable "instance_type" {
    type = string
    default = "t2.micro"
    description = "EC2 instance type"
}

variable "subnet_id" {
  type = string
  description = "Subnet ID where the instance will be deployed"
}

variable "vpc_security_group_ids" {
  type = list(string)
  description = "List of security group IDs"
}

variable "key_name" {
  type = string
  description = "Name of the EC2 key pair"
}

variable "name" {
  type = string
  description = "Tag name for the instance"
}