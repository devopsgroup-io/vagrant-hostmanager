module VagrantPlugins
  module HostManager
    module Util
      def self.get_config(env)
        # config_global has been removed from v1.5
        if Gem::Version.new(::Vagrant::VERSION) >= Gem::Version.new('1.5')
          env.vagrantfile.config
        else
          env.config_global
        end
      end
    end
  end
end