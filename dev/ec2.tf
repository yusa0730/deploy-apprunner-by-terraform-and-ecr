data "aws_ssm_parameter" "amzn2_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_instance" "bastion" {
  ami = data.aws_ssm_parameter.amzn2_ami.value
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ec2.name
  subnet_id = aws_subnet.ec2_public_a.id
  vpc_security_group_ids = [
    aws_security_group.ec2_sg.id
  ]

  user_data = <<EOF
    #!/bin/bash
    rpm -Uvh https://dev.mysql.com/get/mysql57-community-release-el7-8.noarch.rpm
    yum update -y
    rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
    yum install mysql-community-server -y
    EOF

  tags = {
    Name = "${var.env}-bastion-ec2"
  }
}