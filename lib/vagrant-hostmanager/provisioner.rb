module VagrantPlugins
  module HostManager
    class Provisioner < Vagrant.plugin('2', :provisioner)
      include HostsFile

      def initialize(machine, config)
        super(machine, config)
        @global_env = machine.env
        @provider = machine.provider_name
      end

      def provision
        update_guest(@machine)
        if @global_env.config_global.hostmanager.manage_host?
          update_host
        end
      end
    end
  end
end
