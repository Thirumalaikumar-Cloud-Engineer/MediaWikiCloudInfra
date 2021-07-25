#!/bin/bash
apt-get update -y
cd /tmp
sudo apt-get install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb
sudo snap start amazon-ssm-agent
sudo snap services amazon-ssm-agent
sudo snap list amazon-ssm-agent
sudo apt install ansible python3 python3-pip -y
sudo pip3 install PyMySQL


