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

If you already had a cluster running and now want another one, just remove the
first and start the other (see below)

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

The `kubectl join` command to connect the workers to the master node will now
also be performed by the setup

To scale the amount of worker nodes you can change the following line in
the `Vagrantfile`

```ruby
1.upto(1) do |i|
  # change the upto number to the amount of workers you need/want
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
# cd <cluster_name> e.g.:
cd k8s-docker
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


## forgot the join token

- ssh into your master node
- `ifconfig|grep 'inet 192.168.10.1'|awk '{print $2}'|xargs echo -n` to retrieve your master node ip
- `kubeadm token list -o jsonpath='{.token}'` to retrieve the token
- now sha256 it

```shell
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt \
 | openssl rsa -pubin -outform der 2>/dev/null \
 | openssl dgst -sha256 -hex \
 | sed 's/ˆ.* //'
```

- lets combine the above commands to recreate the complete join command...

```shell
echo "sudo kubeadm join $(ifconfig|grep 'inet 192.168.10.1'|awk '{print $2}'|xargs echo -n):6443 --token $(kubeadm token list -o jsonpath='{.token}') --discovery-token-ca-cert-hash $(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/ˆ.* //'|awk '{print $2}')"
```

- now copy the resulting command en perform it on your worker node(s)
