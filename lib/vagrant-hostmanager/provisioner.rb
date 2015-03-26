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
        @global_env.active_machines.each do |name, p|
          if p == @provider
            machine = @global_env.machine(name, p)
            @updater.update_guest(machine)
          end
        end
        if @config.hostmanager.manage_host?
          @updater.update_host
        end
      end
    end
  end
end
