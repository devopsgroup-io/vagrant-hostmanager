module VagrantPlugins
  module HostManager
    class Provisioner < Vagrant.plugin('2', :provisioner)
      include HostsFile

      def provision
        generate(@machine.env, @machine.box.provider.to_sym)
        update(@machine)
      end
    end
  end
end
