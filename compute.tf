#### Resource EC2 

resource "aws_instance" "test_instance" {
  count = (var.cloud_type == "aws") ? 1 : 0
  key_name      = aws_key_pair.comp_generated_key.key_name
  ami           = data.aws_ami.ubuntu_server.id
  instance_type = "t2.micro"
  subnet_id   = aviatrix_vpc.aviatrix_vpc_vnet.subnets[local.subnet_count].subnet_id
  vpc_security_group_ids  = ["${aws_security_group.allow_ssh_icmp_spoke.id}"]
  associate_public_ip_address = true
  connection {
    type     = "ssh"
    user     = "ubuntu"
    host     = self.public_ip
    private_key = var.private_key
#    private_key = file("avtx_priv_key.pem")
  }

  tags = {
    Name = "aws-test-instance"
   # Name = var.vm_name
  }
}


data "aws_ami" "ubuntu_server" {
  most_recent = true
  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["*ubuntu-xenial-16.04-amd64-server-20181114*"]
  }
  filter {
    name = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
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
#

resource "aws_key_pair" "comp_generated_key" {
  key_name   = "${var.key_name}_${var.aws_region}_vpc"
  public_key = var.public_key
}
