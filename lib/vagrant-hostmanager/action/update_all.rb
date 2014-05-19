require 'vagrant-hostmanager/hosts_file'

module VagrantPlugins
  module HostManager
    module Action
      class UpdateAll
        include HostsFile

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @global_env = @machine.env
          @provider = @machine.provider_name

          # config_global is deprecated from v1.5
          if Gem::Version.new(::Vagrant::VERSION) >= Gem::Version.new('1.5')
            @config = @global_env.vagrantfile.config
          else
            @config = @global_env.config_global
          end

          @logger = Log4r::Logger.new('vagrant::hostmanager::update_all')
        end

        def call(env)
          # skip if machine is not active on destroy action
          return @app.call(env) if !@machine.id && env[:machine_action] == :destroy

          # check config to see if the hosts file should be update automatically
          return @app.call(env) unless @config.hostmanager.enabled?
          @logger.info 'Updating /etc/hosts file automatically'

          @app.call(env)

          # update /etc/hosts file on active machines
          env[:ui].info I18n.t('vagrant_hostmanager.action.update_guests')
          @global_env.active_machines.each do |name, p|
            if p == @provider
              machine = @global_env.machine(name, p)
              update_guest(machine)
            end
          end

          # update /etc/hosts files on host if enabled
          if @machine.config.hostmanager.manage_host?
            env[:ui].info I18n.t('vagrant_hostmanager.action.update_host')
            update_host
          end
        end
      end
    end
  end
end
