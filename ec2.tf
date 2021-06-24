resource "aws_security_group" "practice-ec2-sg" {
  count = local.on_ec2 ? 1 : 0

  name = format("%s-%s-%s", local.env, local.service_name, "sg")

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

resource "aws_instance" "practice-ec2-instance" {
  count = local.on_ec2 ? 1 : 0

  # Amazon Linux 2 AMI 2.0.20210525.0 x86_64 HVM gp2
  ami                    = "ami-001f026eaf69770b4"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.practice-ec2-sg[0].id]

  user_data = <<EOF
    #!/bin/bash
    amazon-linux-extras install nginx1
    systemctl start nginx
EOF
}

output "practice-ec2-public-dns" {
  value = local.on_ec2 ? aws_instance.practice-ec2-instance[0].public_dns : ""
}
