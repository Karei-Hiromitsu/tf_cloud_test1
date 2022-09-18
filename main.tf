
provider "aws" {
	# profile = "terraform"
	region = "ap-northeast-1"
	access_key = var.access_key
	secret_key = var.secret_key
}

resource "aws_instance" "hello-world" {
	ami = "ami-0f36dcfcc94112ea1"
	instance_type = "t2.micro"
	tags = {
		Name = var.tag_name
	}

	user_data = <<EOF
#!/bin/bash
amazon-linux-extras install -y nginx1.12
systemctl start nginx
EOF
}

