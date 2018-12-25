provider "aws" {
  region="ap-southeast-2"
}

resource "aws_instance" "web_server" {
  ami = "ami-07a3bd4944eb120a0"
  instance_type = "t2.micro"
  vpc_security_group_ids= ["${aws_security_group.instance.id}"]

  user_data = <<-EOF
                #!/bin/bash
                echo "Hello, World" > index.html
                nohup busybox httpd -f -p "${var.server_port}" &
                EOF
  tags {
      Name="simple-web-server"
      Provided_by="Terraform"
  }
}

resource "aws_security_group" "instance" {
  name="terraform-web-server-security"

  ingress{
      from_port = "${var.server_port}"
      to_port = "${var.server_port}"
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "server_port" {
  description = "The port the web server will use for HTTP requests"
  default = 8080
}

output  "public_ip" {
  value = "${aws_instance.web_server.public_ip}"
}