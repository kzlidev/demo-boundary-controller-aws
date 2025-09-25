resource "tls_private_key" "ssh_key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh_key_pair" {
  key_name   = "${var.friendly_name_prefix}-ssh-key-pair"
  public_key = tls_private_key.ssh_key_pair.public_key_openssh
}

resource "local_file" "ssh_private_key_openssh" {
  filename = "${path.root}/tmp/ssh_private_key"
  content  = tls_private_key.ssh_key_pair.private_key_pem
}

resource "aws_security_group" "ssh_sg" {
  name        = "ssh-access"
  description = "Allow SSH inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from anywhere (adjust as needed)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.cidr_allow_ingress_ec2_ssh_rdp
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion" {
  ami             = coalesce(local.ami_id_list...)
  instance_type   = var.ec2_instance_size
  key_name        = aws_key_pair.ssh_key_pair.key_name
  subnet_id       = element(var.api_lb_subnet_ids, 1)
  security_groups = [aws_security_group.ssh_sg.id]

  tags = {
    Name  = "${var.friendly_name_prefix}-bastion"
  }

  lifecycle {
    ignore_changes = all
  }

  provisioner "file" {
    content     = tls_private_key.ssh_key_pair.private_key_openssh
    destination = "/home/ubuntu/ssh_key"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 /home/ubuntu/ssh_key",
    ]
  }

  connection {
    host        = self.public_ip
    user        = "ubuntu"
    agent       = false
    private_key = tls_private_key.ssh_key_pair.private_key_openssh
  }
}
