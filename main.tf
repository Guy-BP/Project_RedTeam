variable "AWS_SECRET_ACCESS_KEY" {
  description = "AWS secret access key"
  value = "$(AWS_SECRET_KEY)"
}
provider "aws" {
   access_key = "AKIAWGJSY6XBLG5SF6NF" 
   secret_key = var.AWS_SECRET_ACCESS_KEY
   region     = "eu-central-1"
}
    variable "awsprops" {
        default = {
            region = "eu-central-1"
            vpc = "vpc-078c9a7ee61fcfeea"
            ami = "ami-04e601abe3e1a910f"
            itype = "t2.micro"
            subnet = "subnet-060d6a838b66de62c"
            publicip = true
            keyname = "myseckey"
            secgroupname = "Red-Team-SG"
        }
    }
    resource "aws_security_group" "Red-Team-SG" {
        name = "Red-Team-SG"
        description = "Red-Team-SG"
        vpc_id = lookup(var.awsprops, "vpc")

        // To Allow Port 80 Transport
        ingress {
            from_port = 80
            protocol = "tcp"
            to_port = 80
            cidr_blocks = ["0.0.0.0/0"]
        }
        // To Allow Port 443 Transport
        ingress {
            from_port = 443
            protocol = "tcp"
            to_port = 443
            cidr_blocks = ["0.0.0.0/0"]
        }
	ingress {
            from_port = 80
            protocol = "tcp"
            to_port = 3000
            cidr_blocks = ["0.0.0.0/0"]
        }
	ingress {
            from_port = 80
            protocol = "tcp"
            to_port = 3001
            cidr_blocks = ["0.0.0.0/0"]
        }
        egress {
            from_port       = 0
            to_port         = 0
            protocol        = "-1"
            cidr_blocks     = ["0.0.0.0/0"]
        }

        lifecycle {
            create_before_destroy = true
        }
    }
    resource "aws_instance" "appserver" {
        ami = lookup(var.awsprops, "ami")
        instance_type = lookup(var.awsprops, "itype")
        subnet_id = lookup(var.awsprops, "subnet")
        associate_public_ip_address = true
        key_name = "myseckey"
        vpc_security_group_ids = [
            aws_security_group.Red-Team-SG.id
        ]
        root_block_device {
            delete_on_termination = true
            volume_size = 8
            volume_type = "gp2"
        }

	user_data = file("server.sh")
        tags = {
            Name ="SERVER01"
            Environment = "DEV"
            OS = "UBUNTU"
        }

        depends_on = [ aws_security_group.Red-Team-SG ]
    }
        resource "aws_instance" "appfront" {
        ami = lookup(var.awsprops, "ami")
        instance_type = lookup(var.awsprops, "itype")
        subnet_id = lookup(var.awsprops, "subnet")
        associate_public_ip_address = true
        key_name = "myseckey"
        vpc_security_group_ids = [
            aws_security_group.Red-Team-SG.id
        ]
	user_data = file("front.sh")

        root_block_device {
            delete_on_termination = true
            volume_size = 8
            volume_type = "gp2"
        }
        tags = {
            Name ="FRONTENT01"
            Environment = "DEV"
            OS = "UBUNTU"
        }

        depends_on = [ aws_security_group.Red-Team-SG ]
    }
//    output "ec2instance" {
//        value = aws_instance.*.public_ip
//    }
