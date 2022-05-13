#!/bin/bash
echo "Enter the your aws account(e.g. 012345678910) : "
read account

### aws configure
aws configure
region=$(aws configure get region)

### .kube/config
aws eks update-kubeconfig --name mgmt-eks-cluster

### .kube/config simplication
origin="s/arn:aws:eks:$region:$account:cluster\/mgmt-eks-cluster/admin/g"
sed -i $origin /home/ubuntu/.kube/config
#sed -i 's/arn:aws:eks:$region:$account:cluster\/mgmt-eks-cluster/admin/g' /home/ubuntu/.kube/config

