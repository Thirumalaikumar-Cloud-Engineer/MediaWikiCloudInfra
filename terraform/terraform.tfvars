account_id                      = "520847513925"
region                          = "ap-south-1"
project                         = "MediaWiki"

mediawiki_instance_count_main   = 2
mediawiki_instance_count_backup = 1
mediawiki_instance_type         = "t2.micro"
ami_id                          = "ami-0ca2ab3ae61f4a15c"  #AMI Created using Packer and Ansible remote provisioner

vpc_cidr_block                  = "10.0.0.0/16"
subnet1_cidr_block              = "10.0.1.0/24"
subnet2_cidr_block              = "10.0.2.0/24"
subnet1_availability_zone       = "ap-south-1a"
subnet2_availability_zone       = "ap-south-1b"