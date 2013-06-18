require 'vagrant-hostmanager/hosts_file'

module VagrantPlugins
  module HostManager
    module Action
      class DeleteGuests
        include HostsFile

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @logger = Log4r::Logger.new('vagrant::hostmanager::delete_hosts_file')
        end

        def call(env)
          # check if machine is already active
          #return @app.call(env) if @machine.id

          # check config to see if the hosts file should be update automatically
          return @app.call(env) unless @machine.config.hostmanager.enabled?
          @logger.info 'Updating /etc/hosts file automatically'

          # update /etc/hosts file on each active machine
          delete_guests(@machine,@machine.provider_name)

          # continue the action stack so the machine will be created
          @app.call(env)

        end
      end
    end
  end
end
