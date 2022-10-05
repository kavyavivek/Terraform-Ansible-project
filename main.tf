locals {
  ami_id = "ami-09e67e426f25ce0d7"
  vpc_id = "vpc-0a58871f145ac85a9"
  ssh_user = "ubuntu"
  key_name = "Project"
  private_key_path = "/home/labsuser/project/Project.pem"
}

provider "aws" {
  region     = "us-east-1"
  access_key = "ASIA3HIK4XJWK3IOYGTW"
  secret_key = "7YapOWIGN+tKU2GEhwy9D4FskYo6LpkyK8w17lWO"
  token = "FwoGZXIvYXdzEC4aDG5udMvFhrUh9/Dj7yK1AdMZV9wV6qtAVK0T4/0qSPdaVCAyrVb6Z04R4w0QCi6qqyz6P4I5kN4RyCGZRPj0cb4QqLpjLi7rZiPEIsIeGL3/bVsSRMCFbyzdq4DMPyYgojCPZR4nIqaCA1EAD2hjzGEg6JMH1a0zrPwHJ5lCx2fsoixserNujIVt/JlXJejr7+TUtjtCYsFQPZ/AHKz3tzYrzIfpfO3JZBfbR7uMb+PNhLJa8Tj9eCjxEf+ir3BXqlxDZ2gox4D2mQYyLWyLOUohb+dy1tbzO++C/AY73oQzR0vRjI4pETwbEuNALZP/xv8h0W52iODiEg=="
}

resource "aws_security_group" "demoaccess" {
	name   = "demoaccess"
	vpc_id = local.vpc_id

  ingress {
		from_port   = 22
		to_port     = 22
		protocol    = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
  ingress {
		from_port   = 80
		to_port     = 80
		protocol    = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
  egress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

resource "aws_instance" "web" {
  ami = local.ami_id
  instance_type = "t2.micro"
  associate_public_ip_address = "true"
  vpc_security_group_ids =[aws_security_group.demoaccess.id]
  key_name = local.key_name

  tags = {
    Name = "Demo ec2"
  }

  connection {
    type = "ssh"
    host = self.public_ip
    user = local.ssh_user
    private_key = file(local.private_key_path)
    timeout = "4m"
  }

  provisioner "remote-exec" {
    inline = [
      "hostname"
    ]
  }

  provisioner "local-exec" {
    command = "echo ${self.public_ip} > myhosts"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i myhosts --user ${local.ssh_user} --private-key ${local.private_key_path} /home/labsuser/Terraform-ansible/ansible-playbooks/wordpress-lamp_ubuntu1804/playbook.yml"
  }

}

output "instance_ip" {
  value = aws_instance.web.public_ip
}

