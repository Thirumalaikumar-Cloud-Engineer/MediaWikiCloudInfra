packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "ami_prefix" {
  type    = string
  default = "MediaWiki-packer-base-image"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

variable "vpc_id" {
  type    = string
  default = null
}

variable "subnet_id" {
  type    = string
  default = null
}

variable "region" {
  type    = string
  default = null
}

variable "security_group_id" {
  type    = string
  default = null
}


source "amazon-ebs" "ubuntu" {
  ami_name          = "${var.ami_prefix}-${local.timestamp}"
  instance_type     = "t2.micro"
  region            = var.region
  vpc_id            = var.vpc_id
  subnet_id         = var.subnet_id
  security_group_id = var.security_group_id
  ssh_timeout       = "10m"
  ssh_username      = "root"
  ssh_port          = 22
  ssh_pty           = true
  #skip_nat_mapping            = true
  associate_public_ip_address = true

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-focal-20.04-*-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
      root-device-type    = "ebs"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
}

build {
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
  
  provisioner "shell" {
    script = "user_data.sh"
  }

  provisioner "ansible" {
    playbook_file = "mediawiki_installation.yml"
  }
}
