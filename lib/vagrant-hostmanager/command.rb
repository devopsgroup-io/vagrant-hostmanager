module VagrantPlugins
  module HostManager
    class Command < Vagrant.plugin('2', :command)

      # Show description when `vagrant list-commands` is triggered
      def self.synopsis
        "plugin: vagrant-hostmanager: manages the /etc/hosts file within a multi-machine environment"
      end

      def execute
        options = {}
        opts = OptionParser.new do |o|
          o.banner = 'Usage: vagrant hostmanager [vm-name]'
          o.separator ''
          o.version = VagrantPlugins::HostManager::VERSION
          o.program_name = 'vagrant hostmanager'

          o.on('--provider provider', String,
            'Update machines with the specific provider.') do |provider|
            options[:provider] = provider.to_sym
          end
        end

        argv = parse_options(opts)
        options[:provider] ||= @env.default_provider

        # update /etc/hosts file for specified guest machines
        with_target_vms(argv, options) do |machine|
          @env.action_runner.run(Action.update_guest, {
            :global_env => @env,
            :machine => machine,
            :provider => options[:provider]
          })
        end

        # update /etc/hosts file for host
        @env.action_runner.run(Action.update_host, {
          :global_env => @env,
          :provider => options[:provider]
        })
      end
    end
  end
end
