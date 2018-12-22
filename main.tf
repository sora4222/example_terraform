provider "aws" {
    region = "ap-southeast-2"
}

resource "aws_instance" "example" {
  ami = "ami-08589eca6dcc9b39c"
  instance_type = "t2.micro"
  tags{
      Name = "terraformed-ec2-instance"
      Setup_by = "terraform"
      key_name =  "nhung-quick"
  }
}
