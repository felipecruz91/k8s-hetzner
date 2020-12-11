sudo apt-get update \
  && sudo apt-get install -qy docker.io

sudo apt-get update \
  && sudo apt-get install -y apt-transport-https \
  && curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" \
  | sudo tee -a /etc/apt/sources.list.d/kubernetes.list \
  && sudo apt-get update 

sudo apt-get update \
  && sudo apt-get install -yq \
  kubelet=1.19.5-00 \
  kubeadm=1.19.5-00 \
  kubernetes-cni

  sudo apt-mark hold kubelet kubeadm kubectl

  cat /proc/swaps

  sudo kubeadm init --apiserver-advertise-address=10.0.1.5 --kubernetes-version stable-1.19.5 

MASTER ONLY
====

cd $HOME
sudo cp /etc/kubernetes/admin.conf $HOME/
sudo chown $(id -u):$(id -g) $HOME/admin.conf

echo "export KUBECONFIG=$HOME/admin.conf" | tee -a ~/.bashrc
source ~/.bashrc

sudo mkdir -p /var/lib/weave
head -c 16 /dev/urandom | shasum -a 256 | cut -d" " -f1 | sudo tee /var/lib/weave/weave-passwd

kubectl create secret -n kube-system generic weave-passwd --from-file=/var/lib/weave/weave-passwd

kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')&password-secret=weave-passwd&env.IPALLOC_RANGE=192.168.0.0/24"

kubeadm token create --print-join-command


WORKER NODES ONLY
===

kubeadm join 

kubectl get nodes


