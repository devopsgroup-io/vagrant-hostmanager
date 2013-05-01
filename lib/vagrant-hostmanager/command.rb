module VagrantPlugins
  module HostManager
    class Command < Vagrant.plugin('2', :command)
      include HostsFile

      def execute
        options = {}
        opts = OptionParser.new do |o|
          o.banner = 'Usage: vagrant hostmanager [vm-name]'
          o.separator ''

          o.on('--provider provider', String,
            'Update machines with the specific provider.') do |provider|
            options[:provider] = provider
          end
        end

        argv = parse_options(opts)
        return if !argv

        options[:provider] ||= @env.default_provider

        generate(@env, options[:provider].to_sym)

        with_target_vms(argv, options) do |machine|
          update(machine)
        end
      end
    end
  end
end
