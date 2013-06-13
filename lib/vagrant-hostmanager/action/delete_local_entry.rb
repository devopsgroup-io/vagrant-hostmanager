require 'vagrant-hostmanager/hosts_file'

module VagrantPlugins
  module HostManager
    module Action
      class DeleteLocalEntry
        include HostsFile

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @logger = Log4r::Logger.new('vagrant::hostmanager::delete_local_entry')
        end

        def call(env)

          @logger.info 'delete called'
          # check config to see if the hosts file should be updated automatically
          return @app.call(env) unless @machine.config.hostmanager.enabled?
          @logger.info 'Updating /etc/hosts file automatically'

          # delete entry for id
          delete_local(@machine)

          @app.call(env)
        end
      end
    end
  end
end
