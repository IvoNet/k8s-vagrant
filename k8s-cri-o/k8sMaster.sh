#!/usr/bin/env bash

# K8S
sudo sh -c "echo '192.168.10.100 master master' >>/etc/hosts"
sudo apt-get update
sudo apt-get -y upgrade

sudo apt-get -y install curl apt-transport-https net-tools vim git curl wget trace etcd-client

# K8S
sudo sh -c "echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' >> /etc/apt/sources.list.d/kubernetes.list"
sudo sh -c "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -"
K8SVERSION=1.23.5
sudo apt-get update -q -y
sudo apt-get install -q -y kubeadm=${K8SVERSION}-00 kubelet=${K8SVERSION}-00 kubectl=${K8SVERSION}-00
sudo apt-mark hold kubelet kubeadm kubectl

kubectl version --client
kubeadm version

# Disable Swap
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a
echo "sudo swapoff -a" >>${HOME}/.profile

# CRI-O

## Configure sysctl
sudo modprobe overlay
sudo modprobe br_netfilter

lsmod | grep br_netfilter

sudo tee /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system

# CRI-O
export OS="xUbuntu_20.04"
export VERSION="1.23"

sudo sh -c "echo \"deb [signed-by=/usr/share/keyrings/libcontainers-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /\" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list"
sudo sh -c "echo \"deb [signed-by=/usr/share/keyrings/libcontainers-crio-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /\" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list"

sudo mkdir -p /usr/share/keyrings 2>/dev/null
sudo rm -f /usr/share/keyrings/libcontainers-archive-keyring.gpg
sudo rm -f /usr/share/keyrings/libcontainers-crio-archive-keyring.gpg
sudo sh -c "curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | gpg --dearmor -o /usr/share/keyrings/libcontainers-archive-keyring.gpg"
sudo sh -c "curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/Release.key | gpg --dearmor -o /usr/share/keyrings/libcontainers-crio-archive-keyring.gpg"

sudo apt-get update -y -q
sudo apt-get install -y cri-o cri-o-runc

## Start and enable Service
sudo systemctl daemon-reload
sudo systemctl start crio
sudo systemctl enable crio

## Enable kubelet service
sudo systemctl enable kubelet

## kubeadmin config
tee kubeadm-config.yaml <<EOF
apiVersion: kubeadm.k8s.io/v1beta3
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: 192.168.10.100
  bindPort: 6443
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
kubernetesVersion: 1.23.5
controlPlaneEndpoint: "master:6443"
networking:
  podSubnet: 192.168.0.0/16
EOF

## Pull the config images
sudo kubeadm config images pull
## Init the k8s cluster
sudo sh -c "kubeadm init --config=kubeadm-config.yaml --upload-certs | tee kubeadm-init.log"

## Correct the pod-ip address as it will otherwise point to the other network
# https://stackoverflow.com/questions/51154911/kubectl-exec-results-in-error-unable-to-upgrade-connection-pod-does-not-exi
sudo sed -i "s/KUBELET_CONFIG_ARGS=/KUBELET_CONFIG_ARGS=--node-ip=$(ifconfig|grep 'inet 192.168.10.1'|awk '{print $2}'|xargs echo -n) /g" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

## Create the join command in the project folder as join.sh
echo "See 'join.sh' for the join command"
grep -A 1 -E "^kubeadm join"  kubeadm-init.log |tr -d '\\\n'|tr -d "\t"|sed 's/  */ /g'|sed 's/kubeadm/sudo kubeadm/'>/vagrant/k8s-cri-o/join.sh

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

wget -q https://docs.projectcalico.org/manifests/calico.yaml
grep -A 1 CALICO_IPV4POOL_CIDR calico.yaml
kubectl apply -f calico.yaml | tee calico.log


