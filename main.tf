provider "aws" {
    region = "ap-southeast-2"
}

resource "aws_instance" "example" {
  ami = "ami-40d26157"
  instance_type = "t2.micro"
  tags{
      Name = "terraformed-ec2-instance"
      Setup_by = "terraform"
  }
}
