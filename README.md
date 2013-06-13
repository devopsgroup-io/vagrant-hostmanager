Vagrant Host Manager
====================
`vagrant-hostmanager` is a Vagrant 1.1+ plugin that manages the `/etc/hosts`
file on guest machines. Its goal is to enable resolution of multi-machine
environments deployed with a cloud provider where IP addresses are not known
in advance.

Status
------
The current implementation is a proof-of-concept supporting the larger
objective of using Vagrant as a cloud management interface for development
and production environments.

The plugin has been tested with Vagrant 1.1.5.

Installation
------------
Install the plugin following the typical Vagrant 1.1 procedure:

    $ vagrant plugin install vagrant-hostmanager

Usage
-----
To update the `/etc/hosts` file on each active machine, run the following
command:

    $ vagrant hostmanager

The plugin may hook into the `vagrant up` and `vagrant destroy` commands
automatically. When a machine is created or destroyed, all active
machines with the same provider will have their `/etc/hosts` file updated
accordingly. Set the `hostmanager.enabled` attribute to `true` in the
Vagrantfile to activate this behavior.

A machine's IP address is defined by either the static IP for a private
network configuration or by the SSH host configuration. To disable
using the private network IP address, set `config.hostmanger.ignore_private_ip`
to true.

A machine's host name is defined by `config.vm.hostname`. If this is not
set, it falls back to the symbol defining the machine in the Vagrantfile.

When using include_offline set to true, only boxes that are up or have a
private ip configured will be added to the hosts file. You will receive a
warning on skipped boxes.

In addition, the `hostmanager.aliases` configuration attribute can be used
to provide aliases for your host names.

Example configuration:

```ruby
Vagrant.configure("2") do |config|
  config.hostmanager.enabled = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true
  config.vm.define "example-box" do |node|
    node.vm.hostname = "example-box-hostname"
    node.vm.network :private_network, ip: "192.168.42.42"
    node.hostmanager.aliases = %w(example-box.localdomain example-box-alias)
  end
end
```

As a last option, you can also choose hostmanager as a provisioner.
This allows you to use the provisioning order to ensure that hostmanager
runs before or after provisioning. The provisioner will collect hosts from
boxes with the same provider as the running box.

Use:

```ruby
config.vm.provision :hostmanager
```

Contribute
----------
Contributions are welcome.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
