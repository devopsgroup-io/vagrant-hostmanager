require 'tempfile'

module VagrantPlugins
  module HostManager
    module HostsFile
      def update_guest(machine)
        return unless machine.communicate.ready?

        if (machine.communicate.test("uname -s | grep SunOS"))
          realhostfile = '/etc/inet/hosts'
		  move_cmd = 'mv'
        elsif (machine.communicate.test("test -d $Env:SystemRoot"))
		  realhostfile = 'C:\Windows\System32\Drivers\etc\hosts'
		  move_cmd = 'mv -force'
        else 
          realhostfile = '/etc/hosts'
		  move_cmd = 'mv'
        end
        # download and modify file with Vagrant-managed entries
        file = @global_env.tmp_path.join("hosts.#{machine.name}")
        machine.communicate.download(realhostfile, file)
        update_file(file)

        # upload modified file and remove temporary file
        machine.communicate.upload(file, '/tmp/hosts')
        machine.communicate.sudo("#{move_cmd} /tmp/hosts #{realhostfile}")
        # i have no idea if this is a windows competibility issue or not, but sometimes it dosen't work on my machine
        begin
          FileUtils.rm(file) 
        rescue Exception => e
        end
      end

      def update_host
        # copy and modify hosts file on host with Vagrant-managed entries
        file = @global_env.tmp_path.join('hosts.local')
        # add a "if windows..."
        hosts_location = '/etc/hosts'
        copy_cmd = 'sudo cp'
        # handles the windows hosts file...
        if ENV['OS'] == 'Windows_NT'
          hosts_location = "#{ENV['WINDIR']}\\System32\\drivers\\etc\\hosts"
          copy_cmd = 'cp'
        end
        FileUtils.cp(hosts_location, file)
        update_file(file)

        # copy modified file using sudo for permission
        `#{copy_cmd} #{file} #{hosts_location}`
      end

      private

      def update_file(file)
        # build array of host file entries from Vagrant configuration
        entries = []
        destroyed_entries = []
        ids = []
        get_machines.each do |name, p|
          if @provider == p
            machine = @global_env.machine(name, p)
            host = machine.config.vm.hostname || name
            id = machine.id
            ip = get_ip_address(machine)
            aliases = machine.config.hostmanager.aliases.join(' ').chomp
            if id.nil?
              destroyed_entries << "#{ip}\t#{host} #{aliases}"
            else
              entries <<  "#{ip}\t#{host} #{aliases}\t# VAGRANT ID: #{id}\n"
              ids << id unless ids.include?(id)
            end
          end
        end

        tmp_file = Tempfile.open('hostmanager', @global_env.tmp_path, 'a')
        begin
          # copy each line not managed by Vagrant
          File.open(file).each_line do |line|
            # Eliminate lines for machines that have been destroyed
            next if destroyed_entries.any? { |entry| line =~ /^#{entry}\t# VAGRANT ID: .*/ }
            tmp_file << line unless ids.any? { |id| line =~ /# VAGRANT ID: #{id}/ }
          end

          # write a line for each Vagrant-managed entry
          entries.each { |entry| tmp_file << entry }
        ensure
          tmp_file.close
          FileUtils.cp(tmp_file, file)
          tmp_file.unlink
        end
      end

      def get_ip_address(machine)
        ip = nil
        if machine.config.hostmanager.ignore_private_ip != true
          machine.config.vm.networks.each do |network|
            key, options = network[0], network[1]
            ip = options[:ip] if key == :private_network
            next if ip
          end
        end
        ip || (machine.ssh_info ? machine.ssh_info[:host] : nil)
      end

      def get_machines
        if @global_env.config_global.hostmanager.include_offline?
          machines = []
          @global_env.machine_names.each do |name|
            begin
              @global_env.machine(name, @provider)
              machines << [name, @provider]
            rescue Vagrant::Errors::MachineNotFound
            end
          end
          machines
        else
          @global_env.active_machines
        end
      end
    end
  end
end
