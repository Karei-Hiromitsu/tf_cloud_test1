#-----------------------------
#
#-----------------------------
provider "aws" {
	# profile = "terraform"
	region = "ap-northeast-1"
	access_key = var.access_key
	secret_key = var.secret_key
}

resource "aws_instance" "Karei" {
	iam_instance_profile = "AmazonSSMRoleForInstancesQuickSetup"
	ami = "ami-0f36dcfcc94112ea1"
	instance_type = "t2.micro"
	tags = {
		Name = var.tag_name
		ID_Number = var.tag_id_number
	}

	user_data = <<EOF
#!/bin/bash
amazon-linux-extras install -y nginx1.12
systemctl start nginx
EOF
}

