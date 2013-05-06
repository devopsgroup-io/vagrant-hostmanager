module VagrantPlugins
  module HostManager
    module HostsFile
      # Generate a hosts file containing the the active machines
      # in the Vagrant environment backed by the specified provider.
      # The file is written to the Vagrant temporary path.
      def generate(env, provider)
        machines = []

        # define a lambda for looking up a machine's ip address
        get_ip_address = lambda do |machine|
          ip = nil
          if machine.config.hostmanager.ignore_private_ip != true
            machine.config.vm.networks.each do |network|
              key, options = network[0], network[1]
              ip = options[:ip] if key == :private_network
              next if ip
            end
          end
          ip || machine.ssh_info[:host]
        end

        # create the temporary hosts file
        path = env.tmp_path.join('hosts')
        File.open(path, 'w') do |file|
          file << "127.0.0.1\tlocalhost\slocalhost.localdomain\n"
          get_machines(env, provider).each do |name, p|
            if provider == p
              machines << machine = env.machine(name, provider)
              host = machine.config.vm.hostname || name
              ip = get_ip_address.call(machine)
              host_aliases = machine.config.hostmanager.aliases.join("\s").chomp
              machine.env.ui.info I18n.t('vagrant_hostmanager.action.add_host', {
                :ip       => ip,
                :host     => host,
                :aliases  => host_aliases,
              })
              file << "#{ip}\t#{host}\s#{host_aliases}\n"
            end
          end
        end

        machines
      end

      # Copy the temporary hosts file to the specified machine overwritting
      # the existing /etc/hosts file.
      def update(machine)
        path = machine.env.tmp_path.join('hosts')
        if machine.communicate.ready?
          machine.env.ui.info I18n.t('vagrant_hostmanager.action.update', {
            :name => machine.name
          })
          machine.communicate.upload(path, '/tmp/hosts')
          machine.communicate.sudo("mv /tmp/hosts /etc/hosts")
        end
      end

      private
      # Returns an array with the same structure as env.active_machines:
      # [ [:machine, :virtualbox], [:foo, :virtualbox] ]
      def get_machines(env, provider)
        env.active_machines
      end

    end
  end
end
