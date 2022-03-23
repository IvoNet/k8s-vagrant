#!/bin/bash
echo "This script is written to work with Ubuntu 18.04"
sudo swapoff -a
echo "Installing dependencies. This may take a while..."
sudo apt-get update -q -y
sudo apt-get upgrade -y -q
sudo apt-get install -q -y docker.io \
   python3 \
   docker-compose \
   apache2-utils
sudo curl -s -L https://github.com/kubernetes/kompose/releases/download/v1.1.0/kompose-linux-amd64 -o /usr/local/bin/kompose
sudo chmod +x /usr/local/bin/kompose
sudo systemctl start docker
sudo systemctl enable docker
sudo sh -c "echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' >> /etc/apt/sources.list.d/kubernetes.list"
sudo sh -c "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -"
sudo apt-get update -q -y
sudo apt-get install -q -y kubeadm=1.20.1-00 kubelet=1.20.1-00 kubectl=1.20.1-00
sudo apt-mark hold kubelet kubeadm kubectl
sudo kubeadm init --kubernetes-version 1.20.1 \
     --apiserver-advertise-address=192.168.10.100 \
     --ignore-preflight-errors=IsDockerSystemdCheck \
     --pod-network-cidr=192.168.0.0/16 | tee kubeadm-init.log

## Create the join command in the project folder as join.sh
echo "See 'join.sh' for the join command"
grep -A 1 -E "^kubeadm join"  kubeadm-init.log |tr -d '\\\n'|tr -d "\t"|sed 's/  */ /g'|sed 's/kubeadm/sudo kubeadm/'>/vagrant/k8s-docker/join.sh

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

sudo sed -i "s/KUBELET_CONFIG_ARGS=/KUBELET_CONFIG_ARGS=--node-ip=$(ifconfig|grep 'inet 192.168.10.1'|awk '{print $2}'|xargs echo -n) /g" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
sudo cat /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

kubectl get nodes

echo "Script finished."


