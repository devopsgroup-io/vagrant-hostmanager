require 'vagrant-hostmanager/action/update_hosts_file'

module VagrantPlugins
  module HostManager
    class Plugin < Vagrant.plugin('2')
      name 'HostManager'
      description <<-DESC
        This plugin manages the /etc/hosts file for guest machines. An entry is
        created for each active machine using the hostname attribute.
      DESC

      config(:hostmanager) do
        require_relative 'config'
        Config
      end

      action_hook(:hostmanager, :machine_action_up) do |hook|
        hook.prepend(Action::UpdateHostsFile)
      end

      action_hook(:hostmanager, :machine_action_destroy) do |hook|
        hook.append(Action::UpdateHostsFile)
      end

      command(:hostmanager) do
        require_relative 'command'
        Command
      end
    end
  end
end
