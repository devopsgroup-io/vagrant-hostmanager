require 'vagrant-hostmanager/hosts_file'

module VagrantPlugins
  module HostManager
    module Action
      class UpdateLocalEntry
        include HostsFile

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @logger = Log4r::Logger.new('vagrant::hostmanager::update_local_entry')
        end

        def call(env)
          # check if machine is already active
          @logger.info "Called update"
          return @app.call(env) if @machine.id

          # check config to see if the hosts file should be update automatically
          return @app.call(env) unless @machine.config.hostmanager.enabled?
          @logger.info 'Updating /etc/hosts file automatically'

          # continue the action stack so the machine will be created
          @app.call(env)

          # delete entry for id
          update_local(@machine)

        end
      end
    end
  end
end
