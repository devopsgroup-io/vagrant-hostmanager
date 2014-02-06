Vagrant Host Manager
====================
`vagrant-hostmanager` is a Vagrant 1.1+ plugin that manages the `/etc/hosts`
file on guest machines (and optionally the host). Its goal is to enable
resolution of multi-machine environments deployed with a cloud provider
where IP addresses are not known in advance.

*NOTE:* Version 1.1 of the plugin prematurely introduced a feature to hook into
commands other than `vagrant up` and `vagrant destroy`. Version 1.1 broke support for some providers. Version 1.2 reverts this feature until a suitable implementation supporting all providers is available.

Installation
------------
Install the plugin following the typical Vagrant 1.1 procedure:

    $ vagrant plugin install vagrant-hostmanager

Usage
-----
To update the `/etc/hosts` file on each active machine, run the following
command:

    $ vagrant hostmanager

The plugin hooks into the `vagrant up` and `vagrant destroy` commands
automatically.
When a machine enters or exits the running state , all active
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

Example configuration:

```ruby
Vagrant.configure("2") do |config|
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true
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

Custom IP resolver
------------------

You can customize way, how host manager resolves IP address
for each machine. This might be handy in case of aws provider,
where host name is stored in ssh_info hash of each machine.
This causes generation of invalid /etc/hosts file.

Custom IP resolver gives you oportunity to calculate IP address
for each machine by yourself, giving You also access to the machine that is
updating /etc/hosts. For example:

```ruby
config.hostmanager.ip_resolver = proc do |vm, resolving_vm|
  if hostname = (vm.ssh_info && vm.ssh_info[:host])
    `host #{hostname}`.split("\n").last[/(\d+\.\d+\.\d+\.\d+)/, 1]
  end
end
```

Windows support
---------------

Hostmanager will detect Windows guests and hosts and use the appropriate 
path for the ```hosts``` file: ```%WINDIR%\System32\drivers\etc\hosts```

By default on a Windows host, the ```hosts``` file is not writable without
elevated privileges. If hostmanager detects that it cannot overwrite the file,
it will attempt to do so with elevated privileges, causing the 
[UAC](http://en.wikipedia.org/wiki/User_Account_Control) prompt to appear.

### UAC limitations

Due to limitations caused by UAC, cancelling out of the UAC prompt will not cause any
visible errors, however the ```hosts``` file will not be updated.

Contribute
----------
Contributions are welcome.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
