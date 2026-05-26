Vagrant.configure("2") do |config|

  config.vm.define "manager" do |manager|
    manager.vm.box = "/Users/nydiamig/Downloads/focal-server-cloudimg-amd64-vagrant.box"
    manager.vm.hostname = "manager"

    manager.vm.network "private_network", ip: "192.168.56.10"

    manager.vm.synced_folder ".", "/vagrant", type: "virtualbox"

    manager.vm.provider "virtualbox" do |vb|
      vb.name = "manager"
      vb.memory = 4096
      vb.cpus = 2
    end

    # 🔥 ONE COMMAND BOOTSTRAP
    manager.vm.provision "shell", path: "scripts/bootstrap-manager.sh"
  end

  config.vm.define "server1" do |server|
    server.vm.box = "/Users/nydiamig/Downloads/focal-server-cloudimg-amd64-vagrant.box"
    server.vm.hostname = "server1"

    server.vm.network "private_network", ip: "192.168.56.11"

    server.vm.provider "virtualbox" do |vb|
      vb.name = "server1"
      vb.memory = 4096
      vb.cpus = 2
    end
  end

end