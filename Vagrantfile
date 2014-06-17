# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
    config.vm.define "vagrant-net_dev"
    config.vm.box = "net_dev_virtualbox.box"

    # Admin user name and password
    config.winrm.username = "vagrant"
    config.winrm.password = "vagrant"

    config.vm.guest = :windows
    config.windows.halt_timeout = 15

    config.vm.communicator = "winrm"
    config.vm.network :forwarded_port, guest: 5985, host: 5985, id: "winrm", auto_correct: true
    config.vm.network :forwarded_port, guest: 3389, host: 3389, id: "rdp", auto_correct: true
    config.vm.network :forwarded_port, guest: 22, host: 22, id: "ssh", auto_correct: true

    config.vm.synced_folder "~/dev", "/dev"

    config.vm.provider "vmware_fusion" do |v, override|
        v.gui = true
        v.vmx["memsize"] = "2048"
        v.vmx["ethernet0.virtualDev"] = "vmxnet3"
        v.vmx["RemoteDisplay.vnc.enabled"] = "false"
        v.vmx["RemoteDisplay.vnc.port"] = "5900"
        v.vmx["scsi0.virtualDev"] = "lsisas1068"
        v.vmx["gui.fullscreenatpoweron"] = "false"
        v.vmx["gui.viewmodeatpoweron"] = "windowed"
        v.vmx["mks.enable3d"] = "true"
        override.vm.box = "net_dev_vmware.box"
    end

    config.vm.provider "virtualbox" do |v, override|
        v.gui = true
        v.customize ["modifyvm", :id, "--memory", 2048]
        v.customize ["modifyvm", :id, "--ioapic", "on"]
        v.customize ["modifyvm", :id, "--vram", 32]
        override.vm.box = "net_dev_virtualbox.box"
    end
    

    #Copy Resharper license and register if environment var is set
    if ENV['RESHARPER_LICENSE_REGKEY'] != nil
        config.vm.provision "file" do |s|
            s.source = ENV['RESHARPER_LICENSE_REGKEY']
            s.destination = "resharper.reg"
        end

        config.vm.provision "shell",
            inline: 'reg import c:\Users\vagrant\resharper.reg'

        config.vm.provision "shell",
            inline: 'del c:\Users\vagrant\resharper.reg'
    end

    $git_user = `git config user.name`
    config.vm.provision "shell",
        inline: "git config --global user.name \"#$git_user\""

    $git_email = `git config user.email`
    config.vm.provision "shell",
        inline: "git config --global user.email #$git_email"
end
