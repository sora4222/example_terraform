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
  image_id = "ami-07a3bd4944eb120a0"
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

  load_balancers = ["${aws_elb.load_balancer.name}"]
  health_check_type = "ELB"

  tag{
    key = "Name"
    value="Terraform-example"
    propagate_at_launch=true
  }
}

resource "aws_elb" "load_balancer" {
  name="terraform-load-balancer-example"
  availability_zones=["${data.aws_availability_zones.all.names}"]
  security_groups = ["${aws_security_group.elb.id}"]

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "${var.server_port}"
    instance_protocol="http"
  }

  health_check{
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:${var.server_port}/"
  }
}

resource "aws_security_group" "elb" {
  name = "terraform-example-elastic-load-balancer"

  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  egress{
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "Elastic_load_balancer" {
  value = "${aws_elb.load_balancer.dns_name}"
}
