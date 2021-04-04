# Kubernetes 

A vagrant installation for kubernetes on VirtualBox

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

Don't forget to join the workers with the `kubectl join` command as provided 
during the creation of the cluster

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
