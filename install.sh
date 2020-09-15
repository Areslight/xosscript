echo "Installing docker..."
sudo apt-get update
sudo apt-get install -y software-properties-common
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv 0EBFCD88
sudo add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable"
sudo apt-get update
sudo apt-get install -y "docker-ce=17.03*"

echo "Installing kubeadm..."
sudo apt-get update
sudo apt-get install -y ebtables ethtool apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF >/tmp/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo cp /tmp/kubernetes.list /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt install -y "kubernetes-cni=0.6.*"
sudo apt install -y "kubeadm=1.11.3-*" "kubelet=1.11.3-*" "kubectl=1.11.3-*"
sudo swapoff -a
sudo kubeadm init --pod-network-cidr=192.168.0.0/16
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl taint nodes --all node-role.kubernetes.io/master-
kubectl apply -f \
  https://docs.projectcalico.org/v2.6/getting-started/kubernetes/installation/hosted/kubeadm/1.6/calico.yaml
  echo "Installing helm..."
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash
cat > /tmp/helm.yaml <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: helm
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: helm
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: helm
    namespace: kube-system
EOF
kubectl create -f /tmp/helm.yaml
helm init --service-account helm
helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com/
cd ~
mkdir -p cord
cd cord
git clone https://gerrit.opencord.org/helm-charts


cd ~/cord/helm-charts

# Initialize helm
helm init

# Install the xos-core helm chart
helm dep update xos-core
helm install xos-core -n xos-core

# Install the base-kubernetes helm chart
helm dep update xos-profiles/base-kubernetes
helm install xos-profiles/base-kubernetes -n base-kubernetes

# Install the demo-simpleexampleservice helm chart
helm dep update xos-profiles/demo-simpleexampleservice
helm install xos-profiles/demo-simpleexampleservice -n demo-simpleexampleservice