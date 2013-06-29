Vagrant Host Manager
====================
`vagrant-hostmanager` is a Vagrant 1.1+ plugin that manages the `/etc/hosts`
file on guest machines (and optionally the host). Its goal is to enable
resolution of multi-machine environments deployed with a cloud provider
where IP addresses are not known in advance.

Installation
------------
Install the plugin following the typical Vagrant 1.1 procedure:

    $ vagrant plugin install vagrant-hostmanager

If you're using bundler, add the following to your Gemfile

    gem 'vagrant-hostsupdater', :git => 'https://github.comb/asharpe/vagrant-hostmanager'

and also the following to the top of your Vagrantfile

    Vagrant.require_plugin 'vagrant-hostmanager'

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

To update the host's `/etc/hosts` file, set the `hostmanager.manage_host`
attribute to `true`.

A machine's IP address is defined by either the static IP for a private
network configuration or by the SSH host configuration. To disable
using the private network IP address, set `config.hostmanger.ignore_private_ip`
to true.

A machine's host name is defined by `config.vm.hostname`. If this is not
set, it falls back to the symbol defining the machine in the Vagrantfile.

If the `hostmanager.include_offline` attribute is set to `true`, boxes that are
up or have a private ip configured will be added to the hosts file.

In addition, the `hostmanager.aliases` configuration attribute can be used
to provide aliases for your host names.

If you'd like an arbitrary hosts entry to be available to each machine (eg. for
proxy configuration) you can use the `hostmanager.add_host` method to add any
number of entries.

Example configuration:

```ruby
Vagrant.configure("2") do |config|
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true

  config.hostmanager.add_host '192.148.42.1', ['proxy']

  config.vm.define 'example-box' do |node|
    node.vm.hostname = 'example-box-hostname'
    node.vm.network :private_network, ip: '192.168.42.42'
    node.hostmanager.aliases = %w(example-box.localdomain example-box-alias)
  end
end
```

As a last option, you can use hostmanager as a provisioner.
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
