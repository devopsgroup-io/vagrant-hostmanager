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
        hook.after(Vagrant::Action::Builtin::SetHostname, Action.update_all)
      end

      action_hook(:hostmanager, :machine_action_destroy) do |hook|
        hook.prepend(Action.update_all)
      end

      provisioner(:hostmanager) do
        require_relative 'provisioner'
        Provisioner
      end

      # Work-around for vagrant >= 1.5
      # It breaks without a provisioner config, so we provide a dummy one
      config(:hostmanager, :provisioner) do
        ::Vagrant::Config::V2::DummyConfig.new
      end

      command(:hostmanager) do
        require_relative 'command'
        Command
      end
    end
  end
end
