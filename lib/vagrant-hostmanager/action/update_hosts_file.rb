module VagrantPlugins
  module HostManager
    module Action
      class UpdateHostsFile
        def initialize(app, env)
          @app, @env = app, env
          @translator = Helpers::Translator.new('action.update_hosts_file')
          @logger = 
            Log4r::Logger.new('vagrant_hostmanager::action::update')
        end

        def call(env)
          global_env = env[:machine].env
          current_provider = env[:machine].provider_name

          # build a list of host entries based on active machines that
          # are using the same provider as the current one
          matching_machines = []
          entries = {}
          entries['127.0.0.1'] = 'localhost'
          global_env.active_machines.each do |name, provider|
            if provider == current_provider
              machine = global_env.machine(name, provider)
              host = machine.config.vm.hostname || name
              entries[get_ip_address(machine)] = host
              matching_machines << machine
            end
          end

          # generate hosts file
          path = env[:tmp_path].join('hosts')
          File.open(path, 'w') do |file|
            entries.each_pair do |ip, host|
              @logger.info "Adding /etc/hosts entry: #{ip} #{host}"
              file << "#{ip}\t#{host}\n"
            end
          end

          # copy the hosts file to each matching machine
          # TODO append hostname to loopback address
          matching_machines.each do |machine|
            if machine.communicate.ready?
              env[:ui].info @translator.t('update', { :name => machine.name })
              machine.communicate.upload(path, '/tmp/hosts')
              machine.communicate.sudo("mv /tmp/hosts /etc/hosts")
            end
          end

          @app.call(env)
        end

        protected

        def get_ip_address(machine)
          ip = nil
          machine.config.vm.networks.each do |network|
            key, options = network[0], network[1]
            ip = options[:ip] if key == :private_network
            next if ip
          end

          ip || machine.ssh_info[:host]
        end
      end
    end
  end
end
