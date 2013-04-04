require 'vagrant-hostmanager/helpers/translator'
require 'vagrant-hostmanager/action/update_hosts_file'

module VagrantPlugins
  module HostManager
    class Plugin < Vagrant.plugin('2')
      name 'HostManager'
      description <<-DESC
        This plugin manages the /etc/hosts file for guest machines. A entry is
        created for each active machine using the hostname attribute.
      DESC

      action_hook(:hostmanager_up, :machine_action_up) do |hook|
        setup_i18n
        setup_logging
        hook.append(Action::UpdateHostsFile)
      end

      action_hook(:hostmanger_destroy, :machine_action_destroy) do |hook|
        setup_i18n
        setup_logging
        hook.append(Action::UpdateHostsFile)
      end

      def self.setup_i18n
        I18n.load_path << File.expand_path(
          'locales/en.yml',
          HostManager.source_root)
        I18n.reload!

        Helpers::Translator.plugin_namespace = 'vagrant_hostmanager'
      end

      def self.setup_logging
        level = nil
        begin
          level = Log4r.const_get(ENV["VAGRANT_LOG"].upcase)
        rescue NameError
          # This means that the logging constant wasn't found,
          # which is fine. We just keep `level` as `nil`. But
          # we tell the user.
          level = nil
        end

        # Some constants, such as "true" resolve to booleans, so the
        # above error checking doesn't catch it. This will check to make
        # sure that the log level is an integer, as Log4r requires.
        level = nil if !level.is_a?(Integer)

        # Set the logging level on all "vagrant" namespaced
        # logs as long as we have a valid level.
        if level
          logger = Log4r::Logger.new("vagrant_hostmanager")
          logger.outputters = Log4r::Outputter.stderr
          logger.level = level
          logger = nil
        end
      end
    end
  end
end
