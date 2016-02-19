require 'tempfile'

module VagrantPlugins
  module HostManager
    module HostsFile

      class Updater

        def initialize(global_env, provider)
          @global_env = global_env
          @config = Util.get_config(@global_env)
          @provider = provider
          @current_machine_config = nil
        end

        def update_guest(machine)
          return unless machine.communicate.ready?

          if (machine.communicate.test("uname -s | grep SunOS"))
            realhostfile = '/etc/inet/hosts'
          elsif (machine.communicate.test("test -d $Env:SystemRoot"))
            windir = ""
            machine.communicate.execute("echo %SYSTEMROOT%", {:shell => :cmd}) do |type, contents|
              windir << contents.gsub("\r\n", '') if type == :stdout
            end
            realhostfile = "#{windir}\\System32\\drivers\\etc\\hosts"
          else
            realhostfile = '/etc/hosts'
          end
          # download and modify file with Vagrant-managed entries
          file = @global_env.tmp_path.join("hosts.#{machine.name}")
          machine.communicate.download(realhostfile, file)
          @current_machine_config = ((machine && machine.config) || @config)
          if update_file(file, machine, false)

            # upload modified file and remove temporary file
            machine.communicate.upload(file, '/tmp/hosts')
            if windir
              machine.communicate.sudo("mv -force /tmp/hosts/hosts.#{machine.name} #{realhostfile}")
            else
              machine.communicate.sudo("cat /tmp/hosts > #{realhostfile}")
            end
          end

        end

        def update_host
          # copy and modify hosts file on host with Vagrant-managed entries
          file = @global_env.tmp_path.join('hosts.local')

          if WindowsSupport.windows?
            # lazily include windows Module
            class << self
              include WindowsSupport unless include? WindowsSupport
            end

            hosts_location = "#{ENV['WINDIR']}\\System32\\drivers\\etc\\hosts"
            copy_proc = Proc.new { windows_copy_file(file, hosts_location) }
          else
            hosts_location = '/etc/hosts'
            copy_proc = Proc.new { `sudo cp #{file} #{hosts_location}` }
          end

          FileUtils.cp(hosts_location, file)
          if update_file(file)
            copy_proc.call
          end
        end

        private

        def update_file(file, resolving_machine = nil, include_id = true)
          file = Pathname.new(file)
          old_file_content = file.read
          new_file_content = update_content(old_file_content, resolving_machine, include_id)
          file.open('wb') { |io| io.write(new_file_content) }
          old_file_content != new_file_content
        end

        def update_content(file_content, resolving_machine, include_id)
          id = include_id ? " id: #{read_or_create_id}" : ""
          header = "## vagrant-hostmanager-start-#{@provider}#{id}\n"
          footer = "## vagrant-hostmanager-end-#{@provider}\n"
          body = get_machines
            .map { |machine| get_hosts_file_entry(machine, resolving_machine) }
            .join
          get_new_content(header, footer, body, file_content)
        end

        def get_hosts_file_entry(machine, resolving_machine)
          ip = get_ip_address(machine, resolving_machine)

          unless ip.nil?
            names = get_names(machine, resolving_machine)
            if @current_machine_config.hostmanager.aliases_on_separate_lines
              names.map { |a| "#{ip}\t#{a}" }.join("\n") + "\n"
            else
              "#{ip}\t" + names.join(" ") + "\n"
            end
          end
        end

        def get_ip_address(machine, resolving_machine)
          custom_ip_resolver = machine.config.hostmanager.ip_resolver
          if custom_ip_resolver
            custom_ip_resolver.call(machine, resolving_machine)
          else
            ip = nil
            if machine.config.hostmanager.ignore_private_ip != true
              machine.config.vm.networks.each do |network|
                key, options = network[0], network[1]
                ip = options[:ip] if key == :private_network
                break if ip
              end
            end
            ip || (machine.ssh_info ? machine.ssh_info[:host] : nil)
          end
        end

        # get all names including aliases, in the right order (fqdn first if relevant)
        def get_names(machine, resolving_machine)
          host = machine.config.vm.hostname || machine.name
          aliases = machine.config.hostmanager.aliases
          all_names = [host] + aliases

          # Optionally prepend current fqdn as well. Useful with hostname set outside
          # vagrant (eg. aws)
          if @current_machine_config.hostmanager.add_current_fqdn
            dns = get_dns(machine)
            # put fqdn in front
            all_names = dns + all_names
          end

          all_names.uniq # order is kept b uniq
        end

        # return fqdn *and* short name
        def get_dns(machine)
          names = []
          unless machine.nil?
            machine.communicate.execute('/bin/hostname -f') do |type, hostname|
              names += [hostname.strip]
            end
            machine.communicate.execute('/bin/hostname') do |type, hostname|
              names += [hostname.strip]
            end
          end
          names
        end

        def get_machines
          if @config.hostmanager.include_offline?
            machines = @global_env.machine_names
          else
            machines = @global_env.active_machines
              .select { |name, provider| provider == @provider }
              .collect { |name, provider| name }
          end
          # Collect only machines that exist for the current provider
          machines.collect do |name|
                begin
                  machine = @global_env.machine(name, @provider)
                rescue Vagrant::Errors::MachineNotFound
                  # ignore
                end
                machine
              end
            .reject(&:nil?)
        end

        def get_new_content(header, footer, body, old_content)
          if body.empty?
            block = "\n"
          else
            block = "\n\n" + header + body + footer + "\n"
          end
          # Pattern for finding existing block
          header_pattern = Regexp.quote(header)
          footer_pattern = Regexp.quote(footer)
          pattern = Regexp.new("\n*#{header_pattern}.*?#{footer_pattern}\n*", Regexp::MULTILINE)
          # Replace existing block or append
          newcontent = old_content.match(pattern) ? old_content.sub(pattern, block) : old_content.rstrip + block

          ### remove name duplication in 127.*
          cleancontent = ''

          all_names = []
          # First, extract back names from the body. If a name appear there, it
          # should not be anywhere else.
          body.each_line do |line|
            tokens = line.sub(/#.*$/, '').strip.split(/\s+/)
            ip = tokens.shift
            unless tokens.empty?
              all_names += tokens
            end
          end
          puts(all_names)

          # Then remove those names from any 127.* lines
          newcontent.each_line do |line|
            if line =~ /^\s*127\./
              # Here be dragons.
              tokens = line.sub(/#.*$/, '').strip.split(/\s+/)
              ip=tokens.shift
              dedup = tokens - all_names
              unless dedup.empty?
                cleancontent += "#{ip}\t" + dedup.join(' ') + "\n"
              end
            else
              cleancontent += line
            end
          end

          cleancontent

        end

        def read_or_create_id
          file = Pathname.new("#{@global_env.local_data_path}/hostmanager/id")
          if (file.file?)
            id = file.read.strip
          else
            id = SecureRandom.uuid
            file.dirname.mkpath
            file.open('w') { |io| io.write(id) }
          end
          id
        end

        ## Windows support for copying files, requesting elevated privileges if necessary
        module WindowsSupport
          require 'rbconfig'

          def self.windows?
            RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
          end

          require 'win32ole' if windows?

          def windows_copy_file(source, dest)
            begin
              # First, try Ruby copy
              FileUtils.cp(source, dest)
            rescue Errno::EACCES
              # Access denied, try with elevated privileges
              windows_copy_file_elevated(source, dest)
            end
          end

          private

          def windows_copy_file_elevated(source, dest)
            # copy command only supports backslashes as separators
            source, dest = [source, dest].map { |s| s.to_s.gsub(/\//, '\\') }

            # run 'cmd /C copy ...' with elevated privilege, minimized
            copy_cmd = "copy \"#{source}\" \"#{dest}\""
            WIN32OLE.new('Shell.Application').ShellExecute('cmd', "/C #{copy_cmd}", nil, 'runas', 7)

            # Unfortunately, ShellExecute does not give us a status code,
            # and it is non-blocking so we can't reliably compare the file contents
            # to see if they were copied.
            #
            # If the user rejects the UAC prompt, vagrant will silently continue
            # without updating the hostsfile.
          end
        end
      end
    end
  end
end
