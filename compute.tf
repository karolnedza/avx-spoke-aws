####################################################################
# AWS Ubuntu Instance

resource "aws_instance" "test_instance" {
  key_name   = aws_key_pair.key.key_name
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id   = aviatrix_vpc.aviatrix_vpc_vnet.subnets[local.subnet_count].subnet_id
  vpc_security_group_ids  = ["${aws_security_group.allow_ssh_icmp_spoke.id}"]
  associate_public_ip_address = true
    user_data = <<EOF
#!/bin/bash
# allow linuix access by password
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo echo 'ubuntu:Aviatrix123#' | sudo /usr/sbin/chpasswd
sudo /etc/init.d/ssh restart

EOF
  
  connection {
    type     = "ssh"
    user     = "ubuntu"
    host     = self.public_ip
    private_key = var.private_key
  }

  tags = {
    #Name = "aws-test-instance"
     Name = var.vm_name
  }
}


data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

data "aws_route53_zone" "pub" {
  name         = "mcna.cc"
  private_zone = false
}


resource "aws_security_group" "allow_ssh_icmp_spoke" {
  name        = "allow_ssh_icmp"
  description = "Allow SSH & ICMP inbound traffic"
  vpc_id      = aviatrix_vpc.aviatrix_vpc_vnet.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

 
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "ICMP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "key" {
  key_name   = "${var.vm_name}-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCnNDeCuEOgJjtFFzWa9fXyKj8mSdCnCVR+iOm40JYSO4/kKEOflq0VvtIcnezv1wa4Ghj3RqEcFd9857qAQfqsn5KgjwuoYG37eTthz9waKSbem6l8hilR4CncagBqMqje8EDuWFdyNPWmgM04nHJ+HRn0UoXzYikSbbQJ082XORREEpZA4Rt7ZHtIncqN5EMBPQ4lflDOR7l0pCTcGObHNPOuWje35ZQqcjryskUkgvEzx+kFxnJ5fG2cwvDkoq8JrCwXhZNmoYNvR6cAtzMo7S/v7THxCxYMgsSUWRzY1+Pi93EB/CIZp5le0gewblrzXpc8DmHd5NPi3ObPwPTh dennis@NUC"
}

resource "aws_route53_record" "aws_vm_fqdn_pub" {
  zone_id    = data.aws_route53_zone.pub.zone_id
  name       = "${var.vm_name}.pub.mcna.cc"
  type       = "A"
  ttl        = "300"
  records    = [aws_instance.test_instance.public_ip]
}

resource "aws_route53_record" "aws_vm_fqdn_priv" {
  zone_id    = data.aws_route53_zone.pub.zone_id
  name       = "${var.vm_name}.priv.mcna.cc"
  type       = "A"
  ttl        = "300"
  records    = [aws_instance.test_instance.private_ip]
}

