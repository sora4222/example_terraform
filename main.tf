provider "aws" {
  region="ap-southeast-2"
}

variable "server_port" {
  description="The port the server will use for HTTP requests"
  default=8080
}

data "aws_availability_zones" "all" {}


resource "aws_security_group" "instance" {
  name="terraform-example-security-group"

  ingress{
    from_port = "${var.server_port}"
    to_port = "${var.server_port}"
    protocol="tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "template" {
  image_id="ami-40d28157"
  instance_type="t2.micro"
  security_groups= ["${aws_security_group.instance.id}"]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p "${var.server_port}" &
              EOF
  
  lifecycle {
    create_before_destroy = true
  }

}


resource "aws_autoscaling_group" "cluster" {
  launch_configuration="${aws_launch_configuration.template.id}"
  availability_zones=["${data.aws_availability_zones.all.names}"]
  min_size=2
  max_size=5

  tag{
    key = "Name"
    value="Terraform-example"
    propagate_at_launch=true
  }
}