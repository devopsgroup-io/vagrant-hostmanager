module VagrantPlugins
  module HostManager
    class Command < Vagrant.plugin('2', :command)
      include HostsFile

      def execute
        options = {}
        opts = OptionParser.new do |o|
          o.banner = 'Usage: vagrant hostmanager'
          o.separator ''
          o.version = VagrantPlugins::HostManager::VERSION
          o.program_name = 'vagrant hostmanager'

          o.on('--provider provider', String,
            'Update machines with the specific provider.') do |provider|
            options[:provider] = provider
          end
        end

        parse_options(opts)

        options[:provider] ||= @env.default_provider

        update_guests(@env, options[:provider])
        if (@env.config_global.hostmanager.manage_host?)
          update_host(@env, options[:provider])
        end
      end
    end
  end
end
