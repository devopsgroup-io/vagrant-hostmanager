Vagrant Host Manager
====================

[![Gem](https://img.shields.io/gem/v/vagrant-hostmanager.svg)](https://rubygems.org/gems/vagrant-hostmanager)
[![Gem](https://img.shields.io/gem/dt/vagrant-hostmanager.svg)](https://rubygems.org/gems/vagrant-hostmanager)
[![Gem](https://img.shields.io/gem/dtv/vagrant-hostmanager.svg)](https://rubygems.org/gems/vagrant-hostmanager)
[![Twitter](https://img.shields.io/twitter/url/https/github.com/devopsgroup-io/vagrant-hostmanager.svg?style=social)](https://twitter.com/intent/tweet?text=Check%20out%20this%20awesome%20Vagrant%20plugin%21&url=https%3A%2F%2Fgithub.com%devopsgroup-io%2Fvagrant-hostmanager&hashtags=vagrant%hostmanager&original_referer=)

`vagrant-hostmanager` is a Vagrant plugin that manages the `hosts` file on guest machines (and optionally the host). Its goal is to enable resolution of multi-machine environments deployed with a cloud provider where IP addresses are not known in advance.

Do you like what we do? Consider supporting us through Patreon. All of the money goes directly back into growing our collection of open source and free software.
[![Patreon](https://img.shields.io/badge/patreon-donate-red.svg)](https://www.patreon.com/devopsgroup)

Installation
------------

    $ vagrant plugin install vagrant-hostmanager

Usage
-----
To update the `hosts` file on each active machine, run the following
command:

    $ vagrant hostmanager

The plugin hooks into the `vagrant up` and `vagrant destroy` commands
automatically.
When a machine enters or exits the running state, all active
machines with the same provider will have their `/etc/hosts` file updated
accordingly. Set the `hostmanager.enabled` attribute to `true` in the
Vagrantfile to activate this behavior.

To update the host's `hosts` file, set the `hostmanager.manage_host`
attribute to `true`.

To update the guests' `hosts` file, set the `hostmanager.manage_guest`
attribute to `true`.

A machine's IP address is defined by either the static IP for a private
network configuration or by the SSH host configuration. To disable
using the private network IP address, set `config.hostmanager.ignore_private_ip`
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
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true
  config.vm.define 'example-box' do |node|
    node.vm.hostname = 'example-box-hostname'
    node.vm.network :private_network, ip: '192.168.42.42'
    node.hostmanager.aliases = %w(example-box.localdomain example-box-alias)
  end
end
```

### Provisioner

Starting with version 1.5.0, `vagrant up` runs hostmanager before any provisioning occurs. 
If you would like hostmanager to run after or during your provisioning stage, 
you can use hostmanager as a provisioner.  This allows you to use the provisioning 
order to ensure that hostmanager runs when desired. The provisioner will collect
hosts from boxes with the same provider as the running box.

Example:

```ruby
# Disable the default hostmanager behavior
config.hostmanager.enabled = false

# ... possible provisioner config before hostmanager ...

# hostmanager provisioner
config.vm.provision :hostmanager

# ... possible provisioning config after hostmanager ...
```

Custom IP resolver
------------------

You can customize how host manager resolves IP address
for each machine. This might be handy in case of the aws provider,
where host name is stored in the ssh_info hash of each machine.
This causes generation of invalid `/etc/hosts` file.

Custom IP resolver gives you the oportunity to calculate the IP address
for each machine by yourself, giving you also access to the machine that is
updating `/etc/hosts`. For example:

```ruby
config.hostmanager.ip_resolver = proc do |vm, resolving_vm|
  if hostname = (vm.ssh_info && vm.ssh_info[:host])
    `host #{hostname}`.split("\n").last[/(\d+\.\d+\.\d+\.\d+)/, 1]
  end
end
```

Passwordless sudo
-----------------

To avoid being asked for the password every time the hosts file is updated,
enable passwordless sudo for the specific command that hostmanager uses to
update the hosts file.

  - Add the following snippet to the sudoers file (e.g.
    `/etc/sudoers.d/vagrant_hostmanager`):

    ```
    Cmnd_Alias VAGRANT_HOSTMANAGER_UPDATE = /bin/cp <home-directory>/.vagrant.d/tmp/hosts.local /etc/hosts
    %<admin-group> ALL=(root) NOPASSWD: VAGRANT_HOSTMANAGER_UPDATE
    ```

    Replace `<home-directory>` with your actual home directory (e.g.
    `/home/joe`) and `<admin-group>` with the group that is used by the system
    for sudo access (usually `sudo` on Debian/Ubuntu systems and `wheel`
    on Fedora/Red Hat systems).

  - If necessary, add yourself to the `<admin-group>`:

    ```
    usermod -aG <admin-group> <user-name>
    ```

    Replace `<admin-group>` with the group that is used by the system for sudo
    access (see above) and `<user-name>` with you user name.

Windows support
---------------

Hostmanager will detect Windows guests and hosts and use the appropriate
path for the ```hosts``` file: ```%WINDIR%\System32\drivers\etc\hosts```

By default on a Windows host, the ```hosts``` file is not writable without
elevated privileges. If hostmanager detects that it cannot overwrite the file,
it will attempt to do so with elevated privileges, causing the
[UAC](http://en.wikipedia.org/wiki/User_Account_Control) prompt to appear.

To avoid the UAC prompt, open ```%WINDIR%\System32\drivers\etc\``` in
Explorer, right-click the hosts file, go to Properties > Security > Edit
and give your user Modify permission.

### UAC limitations

Due to limitations caused by UAC, cancelling out of the UAC prompt will not cause any
visible errors, however the ```hosts``` file will not be updated.


Compatibility
-------------
This Vagrant plugin has been tested with the following host and guest operating system combinations.

Date Tested | Vagrant Version | vagrant-hostmanager Version | Host (Workstation) Operating System | Guest (VirtualBox) Operating System
------------|-----------------|-----------------------------|-------------------------------------|--------------------------------------
03/23/2016  | 1.8.1           | 1.8.1                       | Ubuntu 14.04 LTS                    | CentOS 7.2
03/22/2016  | 1.8.1           | 1.8.1                       | OS X 10.11.4                        | CentOS 7.2
05/03/2017  | 1.9.4           | 1.8.6                       | macOS 10.12.4                       | Windows Server 2012 R2


Troubleshooting
-------------
* Version 1.1 of the plugin prematurely introduced a feature to hook into
commands other than `vagrant up` and `vagrant destroy`. Version 1.1 broke support
for some providers. Version 1.2 reverts this feature until a suitable implementation
supporting all providers is available.

* Potentially breaking change in v1.5.0: the running order on `vagrant up` has changed
so that hostmanager runs before provisioning takes place.  This ensures all hostnames are 
available to the guest when it is being provisioned 
(see [#73](https://github.com/devopsgroup-io/vagrant-hostmanager/issues/73)).
Previously, hostmanager would run as the very last action.  If you depend on the old behavior, 
see the [provisioner](#provisioner) section.


Contribute
----------
To contribute, fork then clone the repository, and then the following:

**Developing**

1. Install [RVM](https://rvm.io/rvm/install)
2. If using MacOS, follow these [OpenSSL instructions](https://github.com/rvm/rvm/issues/5252#issuecomment-1298835941)
3. Use Ruby v3.0.0 `rvm use 3.0.0`
4. Run `bundle install`

**Testing**

1. Build and package your newly developed code:
    * `rake gem:build`
2. Then install the packaged plugin:
    * `vagrant plugin install pkg/vagrant-hostmanager-*.gem`
3. Once you're done testing, roll-back to the latest released version:
    * `vagrant plugin uninstall vagrant-hostmanager`
    * `vagrant plugin install vagrant-hostmanager`
4. Once you're satisfied developing and testing your new code, please submit a pull request for review.

**Releasing**

To release a new version of vagrant-hostmanager you will need to do the following:

*(only contributors of the GitHub repo and owners of the project at RubyGems will have rights to do this)*

1. First, bump, commit, and push the version in ~/lib/vagrant-hostmanager/version.rb:
    * Follow [Semantic Versioning](http://semver.org/).
2. Then, create a matching GitHub Release (this will also create a tag):
    * Preface the version number with a `v`.
    * https://github.com/devopsgroup-io/vagrant-hostmanager/releases
3. You will then need to build and push the new gem to RubyGems:
    * `rake gem:build`
    * `gem push pkg/vagrant-hostmanager-1.6.1.gem`
4. Then, when John Doe runs the following, they will receive the updated vagrant-hostmanager plugin:
    * `vagrant plugin update`
    * `vagrant plugin update vagrant-hostmanager`
