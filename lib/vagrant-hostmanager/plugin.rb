require 'vagrant-hostmanager/action'

module VagrantPlugins
  module HostManager
    class Plugin < Vagrant.plugin('2')
      name 'HostManager'
      description <<-DESC
        This plugin manages the /etc/hosts file for the host and guest machines.
        An entry is created for each running machine using the hostname attribute.

        You can also use the hostmanager provisioner to update the hosts file.
      DESC

      config(:hostmanager) do
        require_relative 'config'
        Config
      end

      action_hook(:hostmanager, :machine_action_up) do |hook|
        hook.prepend(Action.update_all)
      end

      action_hook(:hostmanager, :machine_action_destroy) do |hook|
        hook.prepend(Action.update_all)
      end

      action_hook(:hostmanager, :machine_action_halt) do |hook|
        hook.prepend(Action.update_all)
      end

      action_hook(:hostmanager, :machine_action_resume) do |hook|
        hook.prepend(Action.update_all)
      end

      action_hook(:hostmanager, :machine_action_suspend) do |hook|
        hook.prepend(Action.update_all)
      end

      provisioner(:hostmanager) do
        require_relative 'provisioner'
        Provisioner
      end

      command(:hostmanager) do
        require_relative 'command'
        Command
      end
    end
  end
end
