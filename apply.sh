#!/bin/bash
echo "Enter the your aws account(e.g. 012345678910) : "
read account

### aws configure
aws configure
region=$(aws configure get region)

### aws-iam-authenticator install
if [ ! -e aws-iam-authenticator* ] ; then
curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/aws-iam-authenticator
chmod +x ./aws-iam-authenticator
mkdir -p $HOME/bin && cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$PATH:$HOME/bin
fi

### .kube/config
aws eks update-kubeconfig --name mgmt-eks-cluster

### .kube/config simplication
origin="s/arn:aws:eks:$region:$account:cluster\/mgmt-eks-cluster/admin/g"
sed -i $origin /home/ubuntu/.kube/config
#sed -i 's/arn:aws:eks:$region:$account:cluster\/mgmt-eks-cluster/admin/g' /home/ubuntu/.kube/config

