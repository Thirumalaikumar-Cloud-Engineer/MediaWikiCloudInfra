#projects and account realted variables
variable "account_id" {}
variable "region" {}
variable "project" {}

#ec2 variables
variable "mediawiki_instance_count_main" {}
variable "mediawiki_instance_count_backup" {}
variable "mediawiki_instance_type" {}

#network and security variables
variable "vpc_cidr_block" {}
variable "subnet1_cidr_block" {}
variable "subnet2_cidr_block" {}
variable "subnet1_availability_zone" {}
variable "subnet2_availability_zone" {}
variable "ami_id" {}

variable "amis" {
  description = "Base AMI to launch the instances"
  default = {
  ap-south-1 = "ami-0ca2ab3ae61f4a15c"
  }
}

#variable setup for Jenkins Ingress
variable "ingressrules" {
  type    = list(number)
  default = [80, 443, 22]
}



