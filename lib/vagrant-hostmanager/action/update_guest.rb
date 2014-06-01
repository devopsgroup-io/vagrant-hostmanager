require 'vagrant-hostmanager/hosts_file'
require 'vagrant-hostmanager/util'

module VagrantPlugins
  module HostManager
    module Action
      class UpdateGuest
        include HostsFile

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @global_env = @machine.env
          @provider = env[:provider]
          @config = Util.get_config(@global_env)
          @logger = Log4r::Logger.new('vagrant::hostmanager::update_guest')
        end

        def call(env)
          env[:ui].info I18n.t('vagrant_hostmanager.action.update_guest', {
            :name => @machine.name
          })
          update_guest(@machine)

          @app.call(env)
        end
      end
    end
  end
end
