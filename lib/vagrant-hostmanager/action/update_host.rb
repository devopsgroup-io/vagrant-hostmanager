require 'vagrant-hostmanager/hosts_file'
require 'vagrant-hostmanager/util'

module VagrantPlugins
  module HostManager
    module Action
      class UpdateHost
        include HostsFile

        def initialize(app, env)
          @app = app
          @global_env = env[:global_env]
          @provider = env[:provider]
          @config = Util.get_config(@global_env)
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

