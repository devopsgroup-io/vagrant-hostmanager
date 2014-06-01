module VagrantPlugins
  module HostManager
    class Provisioner < Vagrant.plugin('2', :provisioner)
      include HostsFile

      def initialize(machine, config)
        super(machine, config)
        @global_env = machine.env
        @provider = machine.provider_name
        @config = Util.get_config(@global_env)
      end

      def provision
        update_guest(@machine)
        if @config.hostmanager.manage_host?
          update_host
        end
      end
    end
  end
end
