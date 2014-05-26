# Changelog

## Upcoming
### Bug fixes
* properly detect hosts file location on Windows guests [[#67](https://github.com/smdahlen/vagrant-hostmanager/pull/67)]
* do not add host if IP cannot be determined [[#85](https://github.com/smdahlen/vagrant-hostmanager/pull/85)]
* force moving of hosts file on Linux guests [[#93](https://github.com/smdahlen/vagrant-hostmanager/pull/93)]
* allow top-level config options (eg. `ip_resolver`) to propagate to machine configs [[#91](https://github.com/smdahlen/vagrant-hostmanager/issues/91)]

### Miscelaneous
* add passwordless sudo instructions to README[[#95](https://github.com/smdahlen/vagrant-hostmanager/pull/95)]

[Full diff](https://github.com/smdahlen/vagrant-hostmanager/compare/v1.4.0...master)  


## 1.4.0
### Features
* supports vagrant 1.5 [[#80](https://github.com/smdahlen/vagrant-hostmanager/issues/80), [#81](https://github.com/smdahlen/vagrant-hostmanager/pull/81)]
* only updates hosts file if contents have changed [[#78](https://github.com/smdahlen/vagrant-hostmanager/pull/78)]
* custom ip resolver now has access to the machine whose hosts file is being updated [[#62](https://github.com/smdahlen/vagrant-hostmanager/pull/62)]

### Bug fixes
* custom IP resolver result no longer ignored [[#57](https://github.com/smdahlen/vagrant-hostmanager/pull/57)]
* when multiple private_networks are configured, the first one is used [[#64](https://github.com/smdahlen/vagrant-hostmanager/pull/64)]
* destroyed machines are now removed from hosts file [[#52](https://github.com/smdahlen/vagrant-hostmanager/pull/52)]

[Full diff](https://github.com/smdahlen/vagrant-hostmanager/compare/v1.3.0...v1.4.0)  


## 1.3.0
### Features
* allow defining a custom IP resolver block [[#15](https://github.com/smdahlen/vagrant-hostmanager/pull/15)]
* handle removing destroyed machines from hosts file (currently only works with `include_offline = true`) [[#45](https://github.com/smdahlen/vagrant-hostmanager/pull/45)]
* attempt to elevate privileges when needed in Windows hosts [[#48](https://github.com/smdahlen/vagrant-hostmanager/pull/48)]

### Bug fixes
* `--provider` command-line option now finds machines as expected [[#46](https://github.com/smdahlen/vagrant-hostmanager/pull/46)]
* uses proper `hosts` file location in Windows under cygwin [[#49](https://github.com/smdahlen/vagrant-hostmanager/pull/49)]

### Miscelaneous
* MIT license added to gemspec

[Full diff](https://github.com/smdahlen/vagrant-hostmanager/compare/v1.2.3...v1.3.0)
