require 'vagrant-hostmanager/hosts_file/updater'
require 'vagrant-hostmanager/util'

module VagrantPlugins
  module HostManager
    module Action
      class UpdateGuest

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @updater = HostsFile::Updater.new(@machine.env, env[:provider])
          @logger = Log4r::Logger.new('vagrant::hostmanager::update_guest')
        end

        def call(env)
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
