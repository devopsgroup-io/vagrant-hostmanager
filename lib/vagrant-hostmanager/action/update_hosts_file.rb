require 'vagrant-hostmanager/hosts_file'

module VagrantPlugins
  module HostManager
    module Action
      class UpdateHostsFile
        include HostsFile

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @translator = Helpers::Translator.new('action.update_hosts_file')
          @logger =
            Log4r::Logger.new('vagrant_hostmanager::action::update')
        end

        def call(env)
          # check config to see if the hosts file should updated automatically
          if @machine.config.hostmanager.auto_update
            # generate temporary hosts file
            machines = generate(@machine.env, @machine.provider_name)

            # update /etc/hosts file on each active machine
            machines.each { |machine| update(machine) }
          end

          @app.call(env)
        end
      end
    end
  end
end
