terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~>3.0"
    }
  }
}

# Configure the AWS provider

provider "aws" {
    region = "us-east-1"
    access_key = "AKIAQE3NRSB6AV547POE"
    secret_key = "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"
}

# Create a VPC

resource "aws_vpc" "MyLab-VPC" {
    cidr_block = var.cidr_block[0]

    tags = {
        Name = "MyLab-VPC"
    }

}

# Create Subnet(Public)

resource "aws_subnet" "MyLab-Subnet1" {
    vpc_id = aws_vpc.MyLab-VPC.id
    cidr_block = var.cidr_block[1]

    tags = {
      Name = "MyLab-Subnet1"
    }
}

# Create Internet Gateway
resource "aws_internet_gateway" "MyLab-IntGw" {
  vpc_id = aws_vpc.MyLab-VPC.id

  tags = {
      Name = "MyLab-InternetGw"
    }
}

# Create Security Group
resource "aws_security_group" "MyLab_Sec_Group" {
  name = "MyLab Security Group"
  description = "In order to allow inbound and outbound traffic to mylab"
  vpc_id = aws_vpc.MyLab-VPC.id

  dynamic ingress {          # Detailing for inbound traffic
    iterator = port
    for_each = var.ports
    
    content {  # Updated area, contents moved in this content section for dynamic ingress controller
    from_port = port.value
    to_port = port.value
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    } 

  }

  egress {           # Detailing for outbound traffic
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  } 

  tags = {
      Name = "Allow Traffic"
    }

}


# Create route table and association

resource "aws_route_table" "MyLab_RouteTable" {
  vpc_id = aws_vpc.MyLab-VPC.id

  route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.MyLab-IntGw.id
  }

  tags = {
  Name = "MyLab_RouteTable"
  }
  
}

resource "aws_route_table_association" "MyLab_Assn" {
  subnet_id = aws_subnet.MyLab-Subnet1.id
  route_table_id = aws_route_table.MyLab_RouteTable.id
}

# Create and Launch AWS EC2 Instance for Jenkins

resource "aws_instance" "Jenkins" {
  ami = var.ami
  instance_type = var.instance_type
  key_name = "EC2-Terraform"
  vpc_security_group_ids = [aws_security_group.MyLab_Sec_Group.id]
  subnet_id = aws_subnet.MyLab-Subnet1.id
  associate_public_ip_address = true
  user_data = file("./InstallJenkins.sh")

  tags = {
    Name = "Jenkins-Server"
  }
}

# Create and Launch AWS EC2 Instance for Ansible Controller Node

resource "aws_instance" "Ansible" {
  ami = var.ami
  instance_type = var.instance_type
  key_name = "EC2-Terraform"
  vpc_security_group_ids = [aws_security_group.MyLab_Sec_Group.id]
  subnet_id = aws_subnet.MyLab-Subnet1.id
  associate_public_ip_address = true
  user_data = file("./InstallAnsibleCN.sh")

  tags = {
    Name = "Ansible-Controller Node"
  }
}

# Create and Launch AWS EC2 Instance for Ansible Managed Node

resource "aws_instance" "AnsibleManagedNode" {
  ami = var.ami
  instance_type = var.instance_type
  key_name = "EC2-Terraform"
  vpc_security_group_ids = [aws_security_group.MyLab_Sec_Group.id]
  subnet_id = aws_subnet.MyLab-Subnet1.id
  associate_public_ip_address = true
  user_data = file("./AnsibleManagedNode.sh")

  tags = {
    Name = "AnsibleMN-Apache Tomcat"
  }
}

# Create and Launch AWS EC2 Instance(Ansible Managed Node2) to Host Docker

resource "aws_instance" "DockerHost" {
  ami = var.ami
  instance_type = var.instance_type
  key_name = "EC2-Terraform"
  vpc_security_group_ids = [aws_security_group.MyLab_Sec_Group.id]
  subnet_id = aws_subnet.MyLab-Subnet1.id
  associate_public_ip_address = true
  user_data = file("./Docker.sh")

  tags = {
    Name = "AnsibleMN-DockerHost"
  }
}

# Create and Launch AWS EC2 Instance to Host Sonatype Nexus

resource "aws_instance" "Nexus" {
  ami = var.ami
  instance_type = var.instance_type_for_nexus
  key_name = "EC2-Terraform"
  vpc_security_group_ids = [aws_security_group.MyLab_Sec_Group.id]
  subnet_id = aws_subnet.MyLab-Subnet1.id
  associate_public_ip_address = true
  user_data = file("./InstallNexus.sh")

  tags = {
    Name = "NexusServer"
  }
}