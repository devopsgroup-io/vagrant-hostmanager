module VagrantPlugins
  module HostManager
    class Provisioner < Vagrant.plugin('2', :provisioner)
      include HostsFile

      def provision
        update_guests(@machine.env, @machine.provider_name)
        if @machine.env.config_global.hostmanager.manage_host?
          update_host(@machine.env, @machine.provider_name)
        end
      end
    end
  end
end
