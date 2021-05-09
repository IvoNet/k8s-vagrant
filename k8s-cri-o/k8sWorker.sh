#!/usr/bin/env bash
sudo sh -c "echo '192.168.10.100 master master' >>/etc/hosts"

sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y install net-tools vim git curl wget

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

export OS="xUbuntu_20.04"
export VERSION="1.21"

sudo sh -c "echo \"deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /\" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list"
sudo sh -c "echo \"deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /\" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list"

sudo sh -c "curl -s -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$VERSION/$OS/Release.key | apt-key add -"
sudo sh -c "curl -s -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | apt-key add -"

sudo apt-get update
sudo apt-get -y install cri-o cri-o-runc

## Start and enable Service
sudo systemctl daemon-reload
sudo systemctl start crio
sudo systemctl enable crio

#K8S

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -q -y kubeadm=1.21.0-00 kubelet=1.21.0-00 kubectl=1.21.0-00
sudo apt-mark hold kubelet kubeadm kubectl
