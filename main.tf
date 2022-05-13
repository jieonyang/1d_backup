module "vpc" {
  source          = "./vpc_module"
  cluster_name    = var.cluster_name
}


module "eks" {
  source = "./eks_module"

  cluster_name      = var.cluster_name
  cluster_node_name = var.cluster_node_name
  node_type         = var.node_type
  node_desired_size = var.node_desired_size
  node_max_size     = var.node_max_size
  node_min_size     = var.node_min_size

  vpc_id     = module.vpc.vpc_id
  subnet_id1 = module.vpc.private_subnet_id[0]
  subnet_id2 = module.vpc.private_subnet_id[1]
}


resource aws_instance "bastion" {
  ami             = var.my_ami
  instance_type   = "t2.micro"
  subnet_id       = module.vpc.public_subnet_id[0]
  private_ip      = "10.0.1.10"
  security_groups = [aws_security_group.bastion_sg.id]
  key_name    = "MyKeyPair"

  tags = {
    Name = "bastion-server" 
  }
}


resource aws_instance "admin" {
  
  ami             = var.my_ami
  instance_type   = "t2.micro"
  subnet_id       = module.vpc.private_subnet_id[0]
  private_ip      = "10.0.10.10"  
  security_groups = [aws_security_group.admin_sg.id]
  key_name    = "MyKeyPair"
  
  user_data = <<EOF
#cloud-boothook
#!/bin/bash -xe

### awscli install
sudo apt-get update
sudo apt-get -y install awscli

### kubectl install
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl=1.23.6-00

### .kube/config
#aws eks --region "{$var.aws_region}" update-kubeconfig --name mgmt-eks-cluster

EOF

  tags = {
    Name = "admin-server"
  }
}


resource "aws_security_group" "bastion_sg" {
  name        = "mgmt_bastion_sg"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mgmt_bastion_sg"
  }
}

resource "aws_security_group" "admin_sg" {
  name        = "mgmt_admin_sg"
  description = "admin server sg"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "SSH from admin-server"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["10.0.1.10/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mgmt_admin_sg"
  }
}
