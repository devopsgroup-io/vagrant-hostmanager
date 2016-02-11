require 'vagrant-hostmanager/hosts_file/updater'
require 'vagrant-hostmanager/util'

module VagrantPlugins
  module HostManager
    module Action
      class UpdateGuest

        def initialize(app, env)
          @app = app
          global_env = env[:global_env]
          @config = Util.get_config(global_env)
          @machine = env[:machine]
          @updater = HostsFile::Updater.new(@machine.env, env[:provider])
          @logger = Log4r::Logger.new('vagrant::hostmanager::update_guest')
        end

        def call(env)
          if @config.hostmanager.manage_guest?
            env[:ui].info I18n.t('vagrant_hostmanager.action.update_guest', {
              :name => @machine.name
            })
            @updater.update_guest(@machine)

            @app.call(env)
          end
        end
      end
    end
  end
end
