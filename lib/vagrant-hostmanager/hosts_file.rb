require 'tempfile'

module VagrantPlugins
  module HostManager
    module HostsFile
      def update_guests(env, provider)
        entries = get_entries(env, provider)
        env.active_machines.each do |name, p|
          if provider == p
            target = env.machine(name, p)
            next unless target.communicate.ready?

            file = env.tmp_path.join("hosts.#{name}")
            target.communicate.download('/etc/hosts', file)
            update_file(file, entries, env.tmp_path)
            target.communicate.upload(file, '/tmp/hosts')
            target.communicate.sudo('mv /tmp/hosts /etc/hosts')
            FileUtils.rm(file)
          end
        end
      end

      def update_host(env, provider)
        entries = get_entries(env, provider)
        file = env.tmp_path.join('hosts.local')
        FileUtils.cp('/etc/hosts', file)
        update_file(file, entries, env.tmp_path)
        `sudo cp #{file} /etc/hosts`
      end

      private

      def update_file(file, entries, tmp_path)
        tmp_file = Tempfile.open('hostmanager', tmp_path, 'a')
        begin
          File.open(file).each_line do |line|
            tmp_file << line unless line =~ /# VAGRANT ID:/
          end
          entries.each { |entry| tmp_file << entry }
        ensure
          tmp_file.close
          FileUtils.cp(tmp_file, file)
          tmp_file.unlink
        end
      end

      def get_entries(env, provider)
        entries = []
        get_machines(env, provider).each do |name, p|
          if provider == p
            machine = env.machine(name, p)
            host = machine.config.vm.hostname || name
            id = machine.id
            ip = get_ip_address(machine)
            aliases = machine.config.hostmanager.aliases.join(' ').chomp
            entries <<  "#{ip}\t#{host} #{aliases}\t# VAGRANT ID: #{id}\n"
          end
        end

        entries
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

      def get_machines(env, provider)
        if env.config_global.hostmanager.include_offline?
          machines = []
          env.machine_names.each do |name|
            begin
              env.machine(name, provider)
              machines << [name, provider]
            rescue Vagrant::Errors::MachineNotFound
            end
          end
          machines
        else
          env.active_machines
        end
      end

    end
  end
end
