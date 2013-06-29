require 'tempfile'
require 'digest/sha1'

module VagrantPlugins
  module HostManager
    module HostsFile
      @@hosts_path = Vagrant::Util::Platform.windows? ? File.expand_path('system32/drivers/etc/hosts', ENV['windir']) : '/etc/hosts'

      def update_guest(machine)
        return unless machine.communicate.ready?

        unless machine.config.hostmanager.enabled?
          @global_env.ui.info I18n.t('vagrant_hostmanager.action.skipping_guest', {
            :name => @machine.name
          })
          return
        end

        @global_env.ui.info I18n.t('vagrant_hostmanager.action.update_guest', {
          :name => @machine.name
        })

        # download and modify file with Vagrant-managed entries
        file = @global_env.tmp_path.join("hosts.#{machine.name}")
        machine.communicate.download('/etc/hosts', file)
        update_file(file, machine)

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

      protected

      # NOTE: this is only necessary if you're working with multiple
      # vagrant environments at the same time
      #
      # This is just for management of the host, each VM gets its
      # hosts file rewritten with the globals and other VM configs
      # each time, however doing the same to the host will remove
      # entries for another environment.
      #
      # id contains
      # - hash of vagrant directory
      #   allows detecting all VMs from an environment
      #   lets us pick up removed/renamed VMs
      # - machine name
      #   detect addresses associated with a specific machine
      #   works when the machine id is missing (ie, not booted yet)
      # - machine id
      #   allows detecting when the machine name has changed


      # returns an array of 
      # [ip, [aliases], id]
      # if target (a machine name) is provided, then include hosts entries
      # for target as well
      def get_vm_entries(baseid, target=nil)
        entries = []
        get_machines.each do |name, p, m|
          if @provider == p
            machine = @global_env.machine(name, p)
            host = machine.config.vm.hostname || name
            id = baseid + [ name, machine.id ]
            ip = get_ip_address(machine)
            aliases = machine.config.hostmanager.aliases.join(' ').chomp
            entries << [ip, [host, aliases].flatten, id]

            # grab the custom hosts entries for the target
            if target and target.name == name
              m.config.hostmanager.hosts.each do |ip, aliases|
                entries << [ip, aliases, id]
              end
            end
          end
        end

        # we'll always need the global entries
        @global_env.config_global.hostmanager.hosts.each do |ip, aliases|
          entries << [ip, aliases, baseid]
        end

        entries
      end

      # when machine is nil we grab the lot
      # otherwise we grab the base config for each vm plus extra hosts for
      # this machine
      def update_file(file, machine=nil)
        baseid = [Digest::SHA1.hexdigest(@global_env.root_path.to_s)]
        lines = []

        get_vm_entries(baseid, machine).each do |ip, aliases, id|
          lines << "#{ip}\t#{aliases.join(' ')}\t# VAGRANT: #{id.join('|')}\n"
        end

        tmp_file = Tempfile.open('hostmanager', @global_env.tmp_path, 'a')
        begin
          # copy each line not managed by this environment
          File.open(file).each_line do |line|
            tmp_file << line unless line =~ /# VAGRANT: #{baseid[0]}/
          end

          # write a line for each managed entry
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
              m = @global_env.machine(name, @provider)
              machines << [name, @provider, m]
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
