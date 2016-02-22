# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-hostmanager/version'

Gem::Specification.new do |gem|
  gem.name          = 'vagrant-hostoverseer'
  gem.version       = VagrantPlugins::HostManager::VERSION
  gem.authors       = ['Shawn Dahlen','Seth Reeser','Guillaume']
  gem.email         = ['shawn@dahlen.me','info@devopsgroup.io','guillaume@lomig.net']
  gem.description   = %q{A Vagrant plugin that manages the /etc/hosts file within a multi-machine environment}
  gem.homepage      = 'https://github.com/lomignet/vagrant-hostoverseer'
  gem.summary       = gem.description
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_development_dependency 'bundler', '~> 1.3'
  gem.add_development_dependency 'rake'
end
