require 'tempfile'

module VagrantPlugins
  module HostManager
    module HostsFile
      @@hosts_path = Vagrant::Util::Platform.windows? ? File.expand_path('system32/drivers/etc/hosts', ENV['windir']) : '/etc/hosts'

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
        FileUtils.cp(@@hosts_path, file)
        update_file(file)

        # copy modified file using sudo for permission
        command = %Q(cp #{file} #{@@hosts_path})
        if !File.writable?(@@hosts_path)
          sudo command
        else
          `#{command}`
        end
      end

      private

      # TODO need to find a way to have host specific entries that apply
      # to the configured host only

      # also need to find a way to not let vagrant environments overwrite
      # each others entries in /etc/hosts (namespace the entries)

      def get_vm_entries
        entries = []
        get_machines.each do |name, p|
          if @provider == p
            machine = @global_env.machine(name, p)
            host = machine.config.vm.hostname || name
            id = machine.id
            ip = get_ip_address(machine)
            aliases = machine.config.hostmanager.aliases.join(' ').chomp
            entries << [ip, [host, aliases].flatten, id]
          end
        end

        @global_env.config_global.hostmanager.hosts.each do |ip, aliases|
          entries << [ip, aliases, 'TODO: a global identifier']
        end

        entries
      end

      def update_file(file)
        lines = []

        get_vm_entries.each do |ip, aliases, id|
          lines << "#{ip}\t#{aliases.join(' ')}\t# VAGRANT ID: #{id}\n"
        end

        tmp_file = Tempfile.open('hostmanager', @global_env.tmp_path, 'a')
        begin
          # copy each line not managed by Vagrant
          File.open(file).each_line do |line|
            tmp_file << line unless line =~ /# VAGRANT ID:/
          end

          # write a line for each Vagrant-managed entry
          lines.each { |line| tmp_file << line }
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
        # check if offline machines should be included in host entries
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

      def sudo(command)
        return if !command
        if Vagrant::Util::Platform.windows?
          `#{command}`
        else
          `sudo #{command}`
        end
      end

    end
  end
end
