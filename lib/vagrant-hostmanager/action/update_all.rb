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
          @logger = Log4r::Logger.new('vagrant::hostmanager::update_all')
        end

        def call(env)
          # skip if machine is running and the action is resume or up
          return @app.call(env) if @machine.state.id == :running && [:resume, :up].include?(env[:machine_action])
          # skip if machine is not running and the action is destroy, halt or suspend
          return @app.call(env) if @machine.state.id != :running && [:destroy, :halt, :suspend].include?(env[:machine_action])
          # skip if machine is not saved and the action is resume
          return @app.call(env) if @machine.state.id != :saved && env[:machine_action] == :resume
          # skip if machine is not running and the action is suspend
          return @app.call(env) if @machine.state.id != :running && env[:machine_action] == :suspend

          # check config to see if the hosts file should be update automatically
          return @app.call(env) unless @machine.config.hostmanager.enabled?
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
