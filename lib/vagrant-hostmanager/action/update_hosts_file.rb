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

          # check config to see if the hosts file should be update automatically
          return @app.call(env) if !@machine.config.hostmanager.auto_update
          @logger.info 'Updating /etc/hosts file automatically'

          # continue the action stack so the machine will be created
          @app.call(env)

          # update /etc/hosts file on each active machine
          machines = generate(@machine.env, @machine.provider_name)
          machines.each { |machine| update(machine) }
        end
      end
    end
  end
end
