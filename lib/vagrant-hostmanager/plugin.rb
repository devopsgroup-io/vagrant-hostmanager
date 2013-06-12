require 'vagrant-hostmanager/action/delete_guests'
require 'vagrant-hostmanager/action/update_guests'
require 'vagrant-hostmanager/action/update_local_entry'
require 'vagrant-hostmanager/action/delete_local_entry'

module VagrantPlugins
  module HostManager
    class Plugin < Vagrant.plugin('2')
      name 'HostManager'
      description <<-DESC
        This plugin manages the /etc/hosts file for guest machines. An entry is
        created for each active machine using the hostname attribute.

        You can also use the hostmanager provisioner to update the hosts file.
      DESC

      config(:hostmanager) do
        require_relative 'config'
        Config
      end

      action_hook(self::ALL_ACTIONS) do |hook|
        hook.after(VagrantPlugins::ProviderVirtualBox::Action::Boot, Action::UpdateGuests)
      end

      action_hook(:hostmanager, :machine_action_up) do |hook|
        hook.prepend(Action::UpdateGuests)
        hook.prepend(Action::UpdateLocalEntry)
      end

      action_hook(:hostmanager, :machine_action_destroy) do |hook|
        hook.prepend(Action::DeleteLocalEntry)
        hook.append(Action::DeleteGuests)
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
