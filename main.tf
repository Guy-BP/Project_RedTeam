provider "aws" {
  access_key = "AKIAZKQK7CSKHOSOCI6E"
  secret_key = var.AWS_SECRET_KEY
  region     = "eu-central-1"
}

variable "awsprops" {
  default = {
    region      = "eu-central-1"
    vpc         = "vpc-0960ef3edfd4bf862"
    ami         = "ami-04e601abe3e1a910f"
    itype       = "t2.micro"
    subnet      = "subnet-0e513cd6e866f3807"
    publicip    = true
    keyname     = "finalProj-guybp"
    secgroupname = "Red-Team-SG"
  }
}

resource "aws_security_group" "Red-Team-SG" {
  name        = "Red-Team-SG"
  description = "Red-Team-SG"
  vpc_id      = lookup(var.awsprops, "vpc")

  ingress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "appserver" {
  ami                          = lookup(var.awsprops, "ami")
  instance_type                = lookup(var.awsprops, "itype")
  subnet_id                    = lookup(var.awsprops, "subnet")
  associate_public_ip_address  = true
  key_name                     = "finalProj-guybp"
  vpc_security_group_ids       = [aws_security_group.Red-Team-SG.id]

  root_block_device {
    delete_on_termination = true
    volume_size           = 8
    volume_type           = "gp2"
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo apt update
    sudo apt-get install ca-certificates curl gnupg
    sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs)  stable"
    sudo apt update
    sudo apt-get install docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo groupadd docker
    sudo usermod -aG docker ubuntu
    docker pull guy66bp/appserver
    sleep 15 # Give the container some time to pull
    docker run -d -p 3001:3001 guy66bp/appserver
  EOF

  tags = {
    Name        = "ProjServer"
    Environment = "DEV"
    OS          = "UBUNTU"
  }

  depends_on = [aws_security_group.Red-Team-SG]
}

resource "aws_instance" "appfront" {
  ami                          = lookup(var.awsprops, "ami")
  instance_type                = lookup(var.awsprops, "itype")
  subnet_id                    = lookup(var.awsprops, "subnet")
  associate_public_ip_address  = true
  key_name                     = "finalProj-guybp"
  vpc_security_group_ids       = [aws_security_group.Red-Team-SG.id]
  user_data                    = <<-EOF
    #! /bin/bash
    sudo apt update
    sudo apt-get install nano
    sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs)  stable"
    sudo apt update
    sudo apt-get install docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo groupadd docker
    sudo usermod -aG docker ubuntu
    docker pull guy66bp/frontapp
    sleep 15 # Give the container some time to pull
    docker run -d -p 3000:3000 guy66bp/appfront
EOF


  root_block_device {
    delete_on_termination = true
    volume_size           = 8
    volume_type           = "gp2"
  }

  tags = {
    Name        = "ProjFront"
    Environment = "DEV"
    OS          = "UBUNTU"
  }

  depends_on = [aws_security_group.Red-Team-SG]
}

// Output "ec2instance" {
//     value = aws_instance.*.public_ip
// }
