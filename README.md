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

### Create Cluster

To create a simple k8s virtualbox cluster just clone this repo and:

```shell
cd <project_dir>
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
now remove the "master:" tekst and login to all your workers and perform the joim command

```shell
#EXAMPLE! Look in your creation loggin (on screen) 
sudo kubeadm join 192.168.10.100:6443 --token wdgnhf.pic45fqtzxfhvbpb \
    --discovery-token-ca-cert-hash sha256:d30a96cab1bf1fc8dc90241f23fba6955a1dc00f15c95012f1ddc75088b8266b    
```


### Master login

```shell
cd <project>
master
```

### Worker login

```shell
cd <project>
worker <worker_number>
#e.g.
worker 1
```

### Cluster shutdown

```shell
cd <project>
down
```

### Cluster boot (start)

```shell
cd <project>
up
```

### Cluster remove 

Note that all will be destroyed!

```shell
cd <project>
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

