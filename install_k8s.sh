#!/bin/bash
echo "Installing docker..."
sudo apt-get update
sudo apt-get install -y software-properties-common

echo "add apt proxy"
sudo bash -c "cat>/etc/apt/apt.conf" << EOF
Acquire::https::proxy "http://172.18.218.123:10809/";
Acquire::http::proxy "http://172.18.218.123:10809/";
EOF

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv 0EBFCD88
sudo add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable"
sudo apt-get update
sudo apt-get install -y "docker-ce=17.06*"

echo "Installing kubeadm..."
sudo apt-get update
sudo apt-get install -y ebtables ethtool apt-transport-https curl

export http_proxy=http://172.18.218.123:10809/
export https_proxy=http://172.18.218.123:10809/

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo bash -c "cat >/tmp/kubernetes.list"<<EOF
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo cp /tmp/kubernetes.list /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install kubernetes-cni=0.7.5*
sudo apt install -y "kubeadm=1.12.7-*" "kubelet=1.12.7-*" "kubectl=1.12.7-*"

unset http_proxy
unset https_proxy

sudo swapoff -a

echo "docker proxy"
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo touch /etc/systemd/system/docker.service.d/http-proxy.conf
sudo bash -c "cat>/etc/systemd/system/docker.service.d/http-proxy.conf"<<EOF
[Service]
Environment="HTTP_PROXY=http://172.18.218.123:10809/"
Environment="HTTPS_PROXY=http://172.18.218.123:10809/"
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker