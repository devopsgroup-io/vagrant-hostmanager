module VagrantPlugins
  module HostManager
    module HostsFile
      def update_guests(machine, provider)
        machines = []

        env = machine.env
        # create the temporary hosts file
        path = env.tmp_path

        #fetch hosts file from each machine
        #for each machine, ensure all machine entries are updated
        # add a hosts entry for each active machine matching the provider
        env.active_machines.each do |name, p|
          if provider == p
            machines << machine = env.machine(name, provider)
            machine.communicate.download('/etc/hosts',path.join("hosts.#{name}"))
          end
        end
        env.active_machines.each do |name, p|
            if provider == p
                machines.each do |m|
                    @logger.info "Adding entry for #{m.name} to hosts.#{name}"
                    update_entry(m,path.join("hosts.#{name}"))
                end
            end
            env.machine(name,p).communicate.upload(path.join("hosts.#{name}"), '/tmp/hosts')
            env.machine(name,p).communicate.sudo("mv /tmp/hosts /etc/hosts")
        end
      end

      # delete victim machine from all guests
      def delete_guests(victim, provider)
        machines = []

        env = victim.env
        # create the temporary hosts file
        path = env.tmp_path

        #fetch hosts file from each machine
        #for each machine, ensure all machine entries are updated
        # add a hosts entry for each active machine matching the provider
        env.active_machines.each do |name, p|
          if provider == p
            machines << machine = env.machine(name, provider)
            machine.communicate.download('/etc/hosts',path.join("hosts.#{name}"))
            delete_entry(victim,path.join("hosts.#{name}"))               
            if machine.communicate.ready?
                machine.env.ui.info I18n.t('vagrant_hostmanager.action.update_guest', {
                    :name => machine.name
                })
                machine.communicate.upload(path.join("hosts.#{name}"), '/tmp/hosts')
                machine.communicate.sudo("mv /tmp/hosts /etc/hosts")
            end
          end
        end
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

      def update_entry(machine,file_name,sudo=false)
         delete_entry(machine,file_name,sudo)
         
         host = machine.config.vm.hostname || name
         id = machine.id
         ip = get_ip_address(machine)
         host_aliases = machine.config.hostmanager.aliases.join("\s").chomp
         host_entry = "#{ip}\t#{host}\s#{host_aliases}\s# VAGRANT: #{id}\n" 
         @logger.info "Adding /etc/hosts entry: #{host_entry}"
         temp_file_name = Dir::Tmpname.make_tmpname(File.join(machine.env.tmp_path,'hostmanager'), nil) 
         FileUtils.cp(file_name, temp_file_name)
         File.open(temp_file_name,'a') do |tempfile|
             @logger.info "writing #{host_entry} to #{tempfile.path}"
             tempfile << host_entry
         end

         if sudo == false
            @logger.info "copy #{temp_file_name} #{file_name}"
            FileUtils.cp(temp_file_name,file_name)
         else
            machine.env.ui.info I18n.t('vagrant_hostmanager.action.run_sudo')
            @logger.warn "Running sudo to replace local hosts file, enter your local password if prompted..."
            @logger.info `sudo cp -v #{temp_file_name} #{file_name}`
         end
      end

      def delete_entry(machine,file_name,sudo=false)
          host = machine.config.vm.hostname || name
          temp_file_name = Dir::Tmpname.make_tmpname(File.join(machine.env.tmp_path,'hostmanager'), nil) 
          tempfile = File.open(temp_file_name,'w') do |f| 
            File.open(file_name,'r').each_line do |line|
              if line.match(/#{machine.id}$/).nil?
                 f << line
              else
                  @logger.info "Matched #{machine.id}"
              end
            end
          end
          if sudo == false
            @logger.info "copy #{temp_file_name} #{file_name}"
                FileUtils.cp(temp_file_name,file_name)
          else
              machine.env.ui.info I18n.t('vagrant_hostmanager.action.run_sudo')
              @logger.info `sudo cp -v #{temp_file_name} #{file_name}`
          end
      end

      def update_local(machine)
         return if machine.id.nil?
         update_entry(machine,'/etc/hosts',true)
      end

      def delete_local(machine)
          return if machine.id.nil?
          delete_entry(machine,'/etc/hosts',true)
      end

      def publish_local(tempfile)
          @logger.info `sudo cp -v #{tempfile} /etc/hosts`
      end


      # Copy the temporary hosts file to the specified machine overwritting
      # the existing /etc/hosts file.
      def update(machine)
        path = machine.env.tmp_path.join('hosts')
        if machine.communicate.ready?
          machine.env.ui.info I18n.t('vagrant_hostmanager.action.update_guest', {
            :name => machine.name
          })
          machine.communicate.download(path, '/etc/hosts')
          machine.communicate.upload(path, '/tmp/hosts')
          machine.communicate.sudo("mv /tmp/hosts /etc/hosts")
        end
      end
    end
  end
end
