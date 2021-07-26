# Create a VPC
resource "aws_vpc" "mediawiki-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "MediaWiki VPC"
  }
}

# Create Web Private Subnet
resource "aws_subnet" "web-subnet-1" {
  vpc_id                  = aws_vpc.mediawiki-vpc.id
  cidr_block              = var.subnet1_cidr_block
  availability_zone       = var.subnet1_availability_zone #hardcoded to test, move later to the variables block
  map_public_ip_on_launch = true

  tags = {
    Name = "MediaWiki-subnet-1"
  }
}

# Create Web Private Subnet
resource "aws_subnet" "web-subnet-2" {
  vpc_id                  = aws_vpc.mediawiki-vpc.id
  cidr_block              = var.subnet2_cidr_block
  availability_zone       = var.subnet2_availability_zone #hardcoded to test, move later to the variables block
  map_public_ip_on_launch = true

  tags = {
    Name = "MediaWiki-subnet-2"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.mediawiki-vpc.id

  tags = {
    Name = "MediaWiki-IGW"
  }
}

# Create Web layber route table
resource "aws_route_table" "web-rt" {
  vpc_id = aws_vpc.mediawiki-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "MediaWiki-RT"
  }
}

# Create Web Subnet association with Web route table
resource "aws_route_table_association" "subnet-one" {
  subnet_id      = aws_subnet.web-subnet-1.id
  route_table_id = aws_route_table.web-rt.id
}

# Create Web Subnet association with Web route table
resource "aws_route_table_association" "subnet-two" {
  subnet_id      = aws_subnet.web-subnet-2.id
  route_table_id = aws_route_table.web-rt.id
}

# Create Application Security Group
resource "aws_security_group" "webserver-sg" {
  name        = "MediaWiki-SG"
  description = "Allow inbound traffic from ALB"
  vpc_id      = aws_vpc.mediawiki-vpc.id

  ingress {
    
        description     = "Allow traffic from web layer"
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
    }
 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MediaWiki-SG"
  }
}

data "aws_availability_zones" "all" {}

resource "aws_lb" "external-elb" {
  name               = "External-LB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.webserver-sg.id]
  subnets            = [aws_subnet.web-subnet-1.id, aws_subnet.web-subnet-2.id]
}

resource "aws_lb_target_group" "external-elb" {
  name     = "ALB-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.mediawiki-vpc.id
}

#update later
# Creating Launch Configuration
resource "aws_launch_configuration" "mediawiki-lc" {
  image_id               = lookup(var.amis,var.region)
  instance_type          = var.mediawiki_instance_type
  security_groups        = [aws_security_group.webserver-sg.id]
  lifecycle {
    create_before_destroy = true
  }
}

# Creating AutoScaling Group
resource "aws_autoscaling_group" "mediawiki-asg" {
  launch_configuration = aws_launch_configuration.mediawiki-lc.id
  availability_zones = ["data.aws_availability_zones.all.names"] #Ref: Its a list of strings with 3 elements - one for each machines. 
  min_size = 2
  max_size = 5
  load_balancers = ["aws_lb.external-elb.name"]
  health_check_type = "ELB"
  tag {
    key = "Name"
    value = "terraform-mediawiki-asg"
    propagate_at_launch = true
  }
} 

#Create EC2 Instance
resource "aws_instance" "mediawiki_main" {
  count                  = var.mediawiki_instance_count_main
  ami                    = var.ami_id
  instance_type          = var.mediawiki_instance_type
  availability_zone      = var.subnet1_availability_zone
  vpc_security_group_ids = [aws_security_group.webserver-sg.id]
  subnet_id              = aws_subnet.web-subnet-1.id

  tags = {
    Name = join("",["MediaWiki-Web-App-Main",count.index+1])
  }

  lifecycle {
      ignore_changes = [user_data, volume_tags]
  }
}

#Create EC2 Instance
resource "aws_instance" "mediawiki_backup" {
  count                  = var.mediawiki_instance_count_backup
  ami                    = var.ami_id
  instance_type          = var.mediawiki_instance_type
  availability_zone      = var.subnet2_availability_zone
  vpc_security_group_ids = [aws_security_group.webserver-sg.id]
  subnet_id              = aws_subnet.web-subnet-2.id

  tags = {
    Name = join("",["MediaWiki-Web-App-Backup",count.index+1])
  }

  lifecycle {
      ignore_changes = [user_data, volume_tags]
  }
}
/* 
resource "aws_lb_target_group_attachment" "external-elb1" {
  target_group_arn = aws_lb_target_group.external-elb.arn
  target_id        = aws_instance.mediawiki_main[count.index]
  port             = 80

  depends_on = [
    aws_instance.mediawiki_main,
  ]
}

resource "aws_lb_target_group_attachment" "external-elb2" {
  target_group_arn = aws_lb_target_group.external-elb.arn
  target_id        = aws_instance.mediawiki_backup[count.index]
  port             = 80

  depends_on = [
    aws_instance.mediawiki_backup,
  ]
} */
