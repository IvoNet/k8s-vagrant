Vagrant.configure("2") do |config|

  # Global stuff for all nodes...
  # source: https://devops.stackexchange.com/questions/1237/how-do-i-configure-ssh-keys-in-a-vagrant-multi-machine-setup
  config.vm.box_check_update = false
  config.vm.box = "ubuntu/bionic64"
  # config.vm.box = "ubuntu/focal64"  # ifconfig not installed standard so back to bionic
  config.vm.provision "file", source: "ssh", destination: "/home/vagrant/.ssh"
  config.vm.provision "file", source: "bin", destination: "/home/vagrant/bin"
  config.vm.provision :shell do |s|
    ssh_pub_key = File.readlines("./ssh/id_rsa.pub").first.strip
    s.inline = <<-SHELL
      mkdir -p /root/.ssh
      echo #{ssh_pub_key} >> /home/vagrant/.ssh/authorized_keys
      echo #{ssh_pub_key} >> /root/.ssh/authorized_keys
      echo "export PATH=~/bin:$PATH" >>/home/vagrant/.profile
      echo "alias docker='sudo docker'" >>/home/vagrant/.profile
      echo "alias dps='sudo docker ps'" >>/home/vagrant/.profile
      echo "alias dpsa='sudo docker ps -a'" >>/home/vagrant/.profile
      echo "alias drmf='sudo docker rm -f'" >>/home/vagrant/.profile
      echo "alias di='sudo docker images'" >>/home/vagrant/.profile
      echo "alias dc='sudo docker-compose'" >>/home/vagrant/.profile
      echo "alias dcu='sudo docker-compose up'" >>/home/vagrant/.profile
      echo "alias dcdv='sudo docker-compose down -v'" >>/home/vagrant/.profile
      echo "alias k='kubectl'" >>/home/vagrant/.profile
      echo "alias h='history'" >>/home/vagrant/.profile
      echo "source <(kubectl completion bash)" >>/home/vagrant/.profile
      echo "complete -F __start_kubectl k" >>/home/vagrant/.profile
      echo "swapoff -a" >>/home/vagrant/.profile
      chmod 600 /home/vagrant/.ssh/*
      chmod +x /home/vagrant/bin/* 
      mkdir -p /etc/docker
      echo '{ "insecure-registries":["registry:5000"] }' >>/etc/docker/daemon.json
      echo '192.168.10.100 master master' >>/etc/hosts
      echo '#IP registry registry' >>/etc/hosts
      echo "set et sts=2 sw=2 ts=2" >/home/vagrant/.vimrc
    SHELL
  end

  # Master Node
  config.vm.define "master", primary: true do |master|
    master.vm.network "private_network", ip: "192.168.10.100"
    master.vm.synced_folder ".", "/vagrant", disabled: true
    master.vm.hostname = "master"
    master.vm.boot_timeout = 60
    master.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.memory = "4096"
      vb.name = "Master"
      vb.cpus = 2
      vb.customize ["modifyvm", :id, "--vram", "20"]
      vb.customize ["modifyvm", :id, "--cpuexecutioncap", "100"]
      vb.customize ["modifyvm", :id, "--ioapic", "on"]
      vb.customize ["modifyvm", :id, "--graphicscontroller", "vmsvga"]
    end
    master.vm.provision "shell", path: "k8sMaster.sh", privileged: false
  end

  # Worker node(s)
  1.upto(2) do |i|  # change the upto number to the amount of workers you need/want
    config.vm.define "worker#{i}" do |workers|
      workers.vm.network "private_network", ip: "192.168.10.11#{i}"
      workers.vm.synced_folder ".", "/vagrant", disabled: true
      workers.vm.hostname = "worker#{i}"
      workers.vm.boot_timeout = 60
      workers.vm.provider "virtualbox" do |vb|
        vb.gui = false
        vb.memory = "2048"
        vb.name = "worker#{i}"
        vb.cpus = 2
        vb.customize ["modifyvm", :id, "--vram", "20"]
        vb.customize ["modifyvm", :id, "--cpuexecutioncap", "100"]
        vb.customize ["modifyvm", :id, "--ioapic", "on"]
        vb.customize ["modifyvm", :id, "--graphicscontroller", "vmsvga"]
      end
      # Copy your own ssh config to your
      workers.vm.provision "shell", path: "k8sWorker.sh", privileged: false
    end
  end
end
