# Kubernetes 

A vagrant installation for kubernetes on VirtualBox.

Note:
- This setup is NOT meant for a prod env.
- Just meant for practice and stuff you know :-)

## Prerequisites

- [VirtualBox](https://www.virtualbox.org/) installed
- [Vagrant](https://www.vagrantup.com/docs/installation) installed 
- enough space and memory


## Usage

Descriptions below... 

It is always good to look at the scripts themselves :-)

NOTE: All commands are assumed to be performed from the root of the project folder


### Create Cluster

To create a simple k8s virtualbox cluster just clone this repo and:

```shell
vagrant up
```

Now be patient... the standard setup (1 master, 2 workers) can easily take 
up to 30 minutes (or longer) to complete depending on you internet 
connection and the speed of your machine

Don't forget to join the workers with the `kubeadm join` command as provided 
during the creation of the cluster.

it will look something like this:

```shell 
kubeadm join 192.168.10.100:6443 --token wdgnhf.pic45fqtzxfhvbpb \
    master:     --discovery-token-ca-cert-hash sha256:d30a96cab1bf1fc8dc90241f23fba6955a1dc00f15c95012f1ddc75088b8266b    
```
now remove the `master:` tekst and login to all your workers and perform the join command

```shell
#EXAMPLE! Look in your creation logging (on screen) 
sudo kubeadm join 192.168.10.100:6443 --token wdgnhf.pic45fqtzxfhvbpb \
    --discovery-token-ca-cert-hash sha256:d30a96cab1bf1fc8dc90241f23fba6955a1dc00f15c95012f1ddc75088b8266b    
```

To scale the ammount of worker nodes u can change the following line in the `Vagrantfile`

```ruby
1.upto(2) do |i|  # change the upto number to the amount of workers you need/want
```

change the `2` to 1 for only one worker, conforming to the cluster used by the 
[LFD259 kubernetes-for-developers by the Linux foundation](https://training.linuxfoundation.org/training/kubernetes-for-developers/)
or to a higher number if you want more workers. Make sure you have enough memory on your host machine :-)

### Master login

```shell
./master
```

### Worker login

```shell
cd <project>
./worker <worker_number>
#e.g.
./worker 1
```

### Cluster shutdown

```shell
./down
```

### Cluster boot (start)

```shell
./up
```

### Cluster remove 

Note that all will be destroyed!

```shell
vagrant destroy [-f]
```

# Troubleshooting

## Creating images fail because already exist

- Goto the Virtualbox VM folder and remove the existing image folder(s)

## cgroupfs warning during installation

```shell
master: 	[WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
```

- Just ignore
