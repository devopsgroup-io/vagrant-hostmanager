module VagrantPlugins
  module HostManager
    module HostsFile
      # Generate a hosts file containing the the active machines
      # in the Vagrant environment backed by the specified provider.
      # The file is written to the Vagrant temporary path.
      def generate(env, provider)
        machines = []


        # create the temporary hosts file
        path = env.tmp_path.join('hosts')
        File.open(path, 'w') do |file|
          file << "127.0.0.1\tlocalhost\slocalhost.localdomain\n"

          # add a hosts entry for each active machine matching the provider
          env.active_machines.each do |name, p|
            if provider == p
              machines << machine = env.machine(name, provider)
              host = machine.config.vm.hostname || name
              id = machine.id
              ip = get_ip_address(machine)
              host_aliases = machine.config.hostmanager.aliases.join("\s").chomp
              host_entry = "#{ip}\t#{host}\s#{host_aliases}\n"
              @logger.info "Adding /etc/hosts entry: #{ip} #{host} #{host_aliases} #{id}"
              file << "#{host_entry}"
            end
          end
        end

        machines
      end

        # define a lambda for looking up a machine's ip address
      def  get_ip_address(machine)
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

      def update_local(machine)
         return if machine.id.nil?
         tmplocal=machine.env.tmp_path.join('hosts.local')
         delete_local(machine)
         
         host = machine.config.vm.hostname || name
         id = machine.id
         ip = get_ip_address(machine)
         host_aliases = machine.config.hostmanager.aliases.join("\s").chomp
         host_entry = "#{ip}\t#{host}\s#{host_aliases}\s# VAGRANT: #{id}\n" 
         @logger.info "Adding /etc/hosts entry: #{ip} #{host} #{host_aliases} # #{id} - #{tmplocal}"
         File.open(tmplocal,'a') do |tmpfile|
             tmpfile << host_entry
         end
         publish_local(machine.env)


      end

      def delete_local(machine)
          return if machine.id.nil?
          tmplocal=machine.env.tmp_path.join('hosts.local')
          File.open(tmplocal, 'w') do |tmpfile|
            File.open('/etc/hosts','r').each_line do |line|
              if line.match(/#{machine.id}$/).nil?
                 @logger.info "Found #{machine.id} in hosts file"
                 tmpfile << line
              end
            end
          end
          publish_local(machine.env)
      end

      def publish_local(env)
          @logger.info `sudo cp -v /etc/hosts /etc/hosts.bak`
          @logger.info `sudo cp -v #{env.tmp_path.join('hosts.local')} /etc/hosts`
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
          machine.communicate.sudo("mv /tmp/hosts /etc/hosts.hostmanager")
        end
      end
    end
  end
end
