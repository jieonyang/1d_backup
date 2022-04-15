#bin/bash
### aws configure
sudo apt-get update
sudo apt-get -y install awscli
aws configure

### terraform install
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt install terraform
echo "Completed!!!!!"
