resource "aws_instance" "web_server" {
  ami = "ami-07a3bd4944eb120a0"
  instance_type = "t2.micro"
  vpc_security_group_ids= ["${aws_security_group.instance.id}"]

  user_data = <<-EOF
                #!/bin/bash
                echo "Hello, World" > index.html
                nohup busybox httpd -f -p 8080 &
                EOF
  tags {
      Name="simple-web-server"
      Provided_by="Terraform"
  }
}

resource "aws_security_group" "instance" {
  name="terraform-web-server-security"

  ingress{
      from_port = 8080
      to_port = 8080
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

