mkdir -p cord
cd cord
git clone https://gerrit.opencord.org/helm-charts

cd ~/cord/helm-charts

helm repo add incubator https://charts.opencord.org
helm dep update xos-core
helm install -n xos-core xos-core

helm dep update xos-profiles/base-kubernetes
helm install -n base-kubernetes xos-profiles/base-kubernetes