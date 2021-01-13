provider "aws" {
   access_key = "AKIAQVPRG34YDUBHQZMX"
   secret_key = "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"
   region     = "us-east-1"
}

resource "aws_instance" "new"{
ami       = "ami-0be2609ba883822ec"
instance_type = "t2.micro"
  availability_zone = "us-east-1a"
   key_name = "hey"
 network_interface {
 device_index = 0
 network_interface_id = aws_network_interface.ani.id
}
 user_data = <<-EOF
           #! /bin/bash
                sudo yum update -y
		sudo yum install -y httpd.x86_64
		sudo service httpd start
		sudo service httpd enable
		echo "<h1>hey! you are done</h1>" | sudo tee /var/www/html/index.html
	EOF

tags = {
Name = "linux"
}
}
resource "aws_vpc" "vpc1" {
cidr_block = "10.0.0.0/16"
tags = {
Name = "New"
}
}
resource "aws_internet_gateway" "gt" {
vpc_id = aws_vpc.vpc1.id
tags = {
Name = "gt1"
}
}
resource "aws_route_table" "r1" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gt.id
  }
  tags = {
    Name = "route1"
  }
}
resource "aws_subnet" "sub1" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "sub1"
  }
}
resource "aws_route_table_association" "asso" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.r1.id
}
resource "aws_security_group" "sg1" {
  name        = "allow_web"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.vpc1.id

  ingress {
    description = "https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg1"
  }
}
resource "aws_network_interface" "ani" {
  subnet_id       = aws_subnet.sub1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.sg1.id]

}
resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.ani.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.gt]  
}
output "id" {
value =  "${aws_instance.new.id}"
}
