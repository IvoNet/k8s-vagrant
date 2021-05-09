# Kubernetes

A few vagrant installations for kubernetes on VirtualBox.

Note:

- These setups are NOT meant for a prod env.
- Just meant for practice and stuff you know :-)

These clusters can be used to practice for the certification programs.

The following cluster configurations are supported at this time:

| Name | Description |
| :---- | :-----------|
| k8s-docker | A cluster on ubuntu 18.04 LTS with 1 master and 1 worker node (default) as needed by the [CKAD certification](https://training.linuxfoundation.org/training/kubernetes-for-developers/) course. It works with cgroups and docker as is used in the Linux Foundation course on k8s version 1.20.1 |
| ubuntu-bare | A master and worker VM will be created but without k8s installed. To practice installing k8s yourself. |
| k8s-cri-o | A k8s cluster with 1 master node and n worker nodes based on the systemd and cri-o in stead of docker |

Note that these clusters will not work next to each other as they use the same
network setup and names. Choose what you want to do or practice and choose one
of the setups. You are of course free to change this. I would appreciate a pull
request then :-).

## Prerequisites

- [VirtualBox](https://www.virtualbox.org/) installed
- [Vagrant](https://www.vagrantup.com/docs/installation) installed
- enough space and memory

## Usage

Descriptions below...

It is always good to look at the scripts themselves :-)

NOTE: All commands are assumed to be performed from the root of the project
folder

### Create Cluster

To create a simple k8s virtualbox cluster just clone this repo and:

```shell
# cd <cluster_name> e.g.:
cd k8s-docker
vagrant up
```

Now be patient... the example setup (1 master, 1 worker) can easily take up to
20 minutes (or longer) to complete depending on you internet connection and the
speed of your machine

Don't forget to join the workers with the `kubeadm join` command as provided
during the creation of the cluster.

it will look something like this:

```shell 
kubeadm join 192.168.10.100:6443 --token wdgnhf.pic45fqtzxfhvbpb \
    master:     --discovery-token-ca-cert-hash sha256:d30a96cab1bf1fc8dc90241f23fba6955a1dc00f15c95012f1ddc75088b8266b    
```

now remove the `master:` tekst and login to all your workers and perform the
join command

```shell
#EXAMPLE! Look in your creation logging (on screen) 
sudo kubeadm join 192.168.10.100:6443 --token 0ghrzs.evvi5r05dok5ongf \
     --discovery-token-ca-cert-hash sha256:d8966c707eb359bce4acb779fbf5a8b941c0f6402c375e205cf5eb21da559c40
```

To scale the amount of worker nodes u can change the following line in
the `Vagrantfile`

```ruby
1.upto(1) do |i|  # change the upto number to the amount of workers you need/want
```

The k8s-docker setup, conforms to the cluster used by the
[LFD259 kubernetes-for-developers by the Linux foundation](https://training.linuxfoundation.org/training/kubernetes-for-developers/)
Change the `upto(1)` number to a higher number if you want more workers. Make
sure you have enough memory on your host machine :-)
Every worker will be assigned 2Gb of RAM. The Master node will be assigned 4Gb
of RAM.

### Master login

```shell
cd <project>
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

