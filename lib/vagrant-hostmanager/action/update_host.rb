require 'vagrant-hostmanager/hosts_file/updater'
require 'vagrant-hostmanager/util'

module VagrantPlugins
  module HostManager
    module Action
      class UpdateHost

        def initialize(app, env)
          @app = app
          
          global_env = env[:global_env]
          @config = Util.get_config(global_env)
          @updater = HostsFile::Updater.new(global_env, env[:provider])
          
          @logger = Log4r::Logger.new('vagrant::hostmanager::update_host')
        end

        def call(env)
          if @config.hostmanager.manage_host?
            env[:ui].info I18n.t('vagrant_hostmanager.action.update_host')
            @updater.update_host
          end

          @app.call(env)
        end
      end
    end
  end
end