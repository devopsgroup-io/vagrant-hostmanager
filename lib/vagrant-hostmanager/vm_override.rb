require 'vagrant'

#debugger

# we're monkeypatching config.vm.define to allow always specifiying the :hostmanager
# key in the configuration for a machine.  Without this the machine will inherit
# the hosts defined in the global :hostmanager config, due to the configuration
# merging login in vagrant - see vagrant/config/loader.rb:151
#require 'plugins/kernel_v2/config/vm'
module VagrantPlugins
  module Kernel_V2
    class VMConfig < Vagrant.plugin("2", :config)
      alias_method :orig_define, :define
      def define(name, options=nil, &block)
        newblock = lambda { |config|
          # if the hostmanager key isn't created, then no merge will be
          # attempted for the hostmanager config, and global hosts
          # entries will leak into each VM config
          # This hack is to ensure that doesn't happen for the
          # case where a VM doesn't set any hosts entries of
          # its own
          config.hostmanager
          block.call(config)
        }        
        orig_define(name, options, &newblock)
      end
    end
  end
end

