module VagrantPlugins
  module HostManager
    class Provisioner < Vagrant.plugin('2', :provisioner)
      include HostsFile

      def provision
         update(@machine)
      end

    end
  end
end
