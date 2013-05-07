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
        options[:provider] ||= @env.default_provider

        with_target_vms(argv, options) do |machine|
          update_guests(machine, machine.provider_name)
          update_local(machine)
        end
      end
    end
  end
end
