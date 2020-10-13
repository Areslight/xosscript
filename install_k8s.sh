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
cat<<EOF>/etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=http://172.18.218.123:10809/"
Environment="HTTPS_PROXY=http://172.18.218.123:10809/"
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker

sudo kubeadm init --pod-network-cidr=192.168.0.0/16
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


kubectl taint nodes --all node-role.kubernetes.io/master-

kubectl apply -f \
  https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml
kubectl apply -f \
  https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml

echo "Installing helm..."
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > install-helm.sh
bash install-helm.sh -v v2.12.1
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
helm init --service-account tiller