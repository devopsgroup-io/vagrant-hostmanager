require 'vagrant-hostmanager/action/update_all'
require 'vagrant-hostmanager/action/update_guest'
require 'vagrant-hostmanager/action/update_host'

module VagrantPlugins
  module HostManager
    module Action
      include Vagrant::Action::Builtin

      def self.update_all
        Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use UpdateAll
        end
      end

      def self.update_guest
        Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use UpdateGuest
        end
      end

      def self.update_host
        Vagrant::Action::Builder.new.tap do |builder|
          builder.use UpdateHost
        end
      end
    end
  end
end
