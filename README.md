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
The plugin hooks into the `vagrant up` and `vagrant destroy` commands
automatically. When a machine is created or destroyed, all active
machines with the same provider will have their `/etc/hosts` file updated
accordingly. Auto update may be disabled by setting the
`config.hostmanager.auto_update` attribute to false in the Vagrantfile.

To update the `/etc/hosts` file on each active machine manually, run the
following command:

    $ vagrant hostmanager

A machine's IP address is defined by either the static IP for a private
network configuration or by the SSH host configuration. To disable
using the private network IP address, set `config.hostmanger.ignore_private_ip`
to true.

A machine's host name is defined by `config.vm.hostname`. If this is not
set, it falls back to the symbol defining the machine in the Vagrantfile.

Contribute
----------
Contributions are welcome.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
