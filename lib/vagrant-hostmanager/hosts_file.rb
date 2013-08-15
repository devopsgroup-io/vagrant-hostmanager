require 'tempfile'

module VagrantPlugins
  module HostManager
    module HostsFile
      def update_guest(machine)
        return unless machine.communicate.ready?

        # download and modify file with Vagrant-managed entries
        file = @global_env.tmp_path.join("hosts.#{machine.name}")
        machine.communicate.download('/etc/hosts', file)
        update_file(file)

        # upload modified file and remove temporary file
        machine.communicate.upload(file, '/tmp/hosts')
        machine.communicate.sudo('mv /tmp/hosts /etc/hosts')
        FileUtils.rm(file)
      end

      def update_host
        # copy and modify hosts file on host with Vagrant-managed entries
        file = @global_env.tmp_path.join('hosts.local')
        FileUtils.cp('/etc/hosts', file)
        update_file(file)

        # copy modified file using sudo for permission
        `sudo cp #{file} /etc/hosts`
      end

      private

      def update_file(file)
        # build array of host file entries from Vagrant configuration
        entries = []
        get_machines.each do |name, p|
          if @provider == p
            machine = @global_env.machine(name, p)
            host = machine.config.vm.hostname || name
            id = machine.id
            ip = get_ip_address(machine)
            aliases = machine.config.hostmanager.aliases.join(' ').chomp
            entries <<  "#{ip}\t#{host} #{aliases}\t# VAGRANT ID: #{id}\n"
          end
        end

        tmp_file = Tempfile.open('hostmanager', @global_env.tmp_path, 'a')
        begin
          # copy each line not managed by Vagrant
          File.open(file).each_line do |line|
            tmp_file << line unless line =~ /# VAGRANT ID:/
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
        machines = []
        @global_env.machine_names.each do |name|
          begin
            machine = @global_env.machine(name, @provider)

            # check if offline machines should be included in host entries
            if @global_env.config_global.hostmanager.include_offline? || machine.state.id == :running 
              machines << [name, @provider]
            end
          rescue Vagrant::Errors::MachineNotFound
          end
        end
        machines
      end

    end
  end
end
