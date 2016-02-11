require 'vagrant-hostmanager/hosts_file/updater'

module VagrantPlugins
  module HostManager
    class Provisioner < Vagrant.plugin('2', :provisioner)

      def initialize(machine, config)
        super(machine, config)
        global_env = machine.env
        @config = Util.get_config(global_env)
        @updater = HostsFile::Updater.new(global_env, machine.provider_name)
      end

      def provision
        if @config.hostmanager.manage_guest?
          @updater.update_guest(@machine)
        end
        if @config.hostmanager.manage_host?
          @updater.update_host
        end
      end
    end
  end
end
