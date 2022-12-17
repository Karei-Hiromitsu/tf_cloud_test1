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
	ami = "ami-072bfb8ae2c884cc4"
	instance_type = "t3.small"
	subnet_id = "subnet-03ce2ed25292358cd"
	tags = {
		Name = var.tag_name
		ID_Number = var.tag_id_number
	}

	user_data = <<EOF
#!/bin/bash
yum update -y

amazon-linux-extras install -y nginx1.12
systemctl start nginx

amazon-linux-extras install -y docker
systemctl start docker
systemctl enable docker


curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x ./minikube && mv -f ./minikube /usr/bin/
yum install -y conntrack

curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kubectl
chmod +x ./kubectl && mv -f ./kubectl /usr/local/bin

#---------
mkdir /tmp/work
cd /tmp/work


# crictl
cd /tmp/work
VERSION="v1.25.0"
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-amd64.tar.gz
tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/bin


###Install GO###
#wget https://storage.googleapis.com/golang/getgo/installer_linux
#chmod +x ./installer_linux
#./installer_linux

amazon-linux-extras install -y golang1.11
source ~/.bash_profile

yum install -y git
git clone https://github.com/Mirantis/cri-dockerd.git


#---------
echo '#!/bin/bash' | tee /tmp/work/minikube_memo.txt
echo 'sudo usermod -a -G docker ssm-user' | tee -a /tmp/work/minikube_memo.txt
echo 'MYNAME=`whoami`' | tee -a /tmp/work/minikube_memo.txt
echo 'sudo chown -R $MYNAME:$MYNAME /tmp/work' | tee -a /tmp/work/minikube_memo.txt
echo 'cd /tmp/work/cri-dockerd' | tee -a /tmp/work/minikube_memo.txt
echo 'mkdir bin' | tee -a /tmp/work/minikube_memo.txt
echo 'go build -o bin/cri-dockerd' | tee -a /tmp/work/minikube_memo.txt
echo 'sudo install -o root -g root -m 0755 bin/cri-dockerd /usr/local/bin/cri-dockerd' | tee -a /tmp/work/minikube_memo.txt
echo 'sudo cp -a packaging/systemd/* /etc/systemd/system' | tee -a /tmp/work/minikube_memo.txt
echo 'sudo sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service' | tee -a /tmp/work/minikube_memo.txt
echo 'sudo systemctl daemon-reload' | tee -a /tmp/work/minikube_memo.txt
echo 'sudo systemctl enable cri-docker.service' | tee -a /tmp/work/minikube_memo.txt
echo 'sudo systemctl enable --now cri-docker.socket' | tee -a /tmp/work/minikube_memo.txt
# echo 'minikube start --vm-driver=none' | tee -a /tmp/work/minikube_memo.txt
echo 'minikube start --vm-driver=none --kubernetes-version=v1.23.0' | tee -a /tmp/work/minikube_memo.txt
echo 'sudo ln -s `find /var/lib/minikube/binaries/ -name kubeadm` /usr/sbin/' | tee -a /tmp/work/minikube_memo.txt

chmod +x /tmp/work/minikube_memo.txt

usermod -a -G docker ec2-user
usermod -a -G docker ssm-user
EOF
}

