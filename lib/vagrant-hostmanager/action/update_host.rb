require 'vagrant-hostmanager/hosts_file'

module VagrantPlugins
  module HostManager
    module Action
      class UpdateHost
        include HostsFile

        def initialize(app, env)
          @app = app
          @global_env = env[:global_env]
          @provider = env[:provider]

          # config_global is deprecated from v1.5
          if Gem::Version.new(::Vagrant::VERSION) >= Gem::Version.new('1.5')
            @config = @global_env.vagrantfile.config
          else
            @config = @global_env.config_global
          end

          @logger = Log4r::Logger.new('vagrant::hostmanager::update_host')
        end

        def call(env)
          if @config.hostmanager.manage_host?
            env[:ui].info I18n.t('vagrant_hostmanager.action.update_host')
            update_host
          end

          @app.call(env)
        end
      end
    end
  end
end

