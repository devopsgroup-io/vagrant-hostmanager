require 'vagrant-hostmanager/hosts_file'

module VagrantPlugins
  module HostManager
    module Action
      class UpdateHostsFile
        include HostsFile

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @logger = Log4r::Logger.new('vagrant::hostmanager::update_hosts_file')
        end

        def call(env)
          # check if machine is already active
          return @app.call(env) if @machine.id
          @logger.info 'Continuing update of hosts file for new machine'

          # check config to see if the hosts file should be update automatically
          return @app.call(env) unless @machine.config.hostmanager.enabled?
          @logger.info 'Updating /etc/hosts file automatically'

          @app.call(env)

          # update /etc/hosts file on active machines
          env[:ui].info I18n.t('vagrant_hostmanager.action.update_guests')
          update_guests(@machine.env, @machine.provider_name)

          # update /etc/hosts files on host if enabled
          if @machine.config.hostmanager.manage_host?
            env[:ui].info I18n.t('vagrant_hostmanager.action.update_host')
            update_host(@machine.env, @machine.provider_name)
          end
        end
      end
    end
  end
end
