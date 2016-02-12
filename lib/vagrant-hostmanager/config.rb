require 'rbconfig'

module VagrantPlugins
  module HostManager
    class Config < Vagrant.plugin('2', :config)
      attr_accessor :enabled
      attr_accessor :manage_host
      attr_accessor :manage_guest
      attr_accessor :ignore_private_ip
      attr_accessor :aliases
      attr_accessor :include_offline
      attr_accessor :ip_resolver
      attr_accessor :path_to_cp

      alias_method :enabled?, :enabled
      alias_method :include_offline?, :include_offline
      alias_method :manage_host?, :manage_host
      alias_method :manage_guest?, :manage_guest

      def initialize
        @enabled            = UNSET_VALUE
        @manage_host        = UNSET_VALUE
        @manage_guest       = UNSET_VALUE
        @ignore_private_ip  = UNSET_VALUE
        @include_offline    = UNSET_VALUE
        @aliases            = UNSET_VALUE
        @ip_resolver        = UNSET_VALUE
        @path_to_cp         = '/bin/cp'
      end

      def finalize!
        @enabled            = false if @enabled == UNSET_VALUE
        @manage_host        = false if @manage_host == UNSET_VALUE
        @manage_guest       = true if @manage_guest == UNSET_VALUE
        @ignore_private_ip  = false if @ignore_private_ip == UNSET_VALUE
        @include_offline    = false if @include_offline == UNSET_VALUE
        @aliases            = [] if @aliases == UNSET_VALUE
        @ip_resolver        = nil if @ip_resolver == UNSET_VALUE
        @path_to_cp         = nil if @path_to_cp == UNSET_VALUE

        @aliases = [ @aliases ].flatten
      end

      def validate(machine)
        errors = []

        errors << validate_bool('hostmanager.enabled', @enabled)
        errors << validate_bool('hostmanager.manage_host', @manage_host)
        errors << validate_bool('hostmanager.manage_guest', @manage_guest)
        errors << validate_bool('hostmanager.ignore_private_ip', @ignore_private_ip)
        errors << validate_bool('hostmanager.include_offline', @include_offline)
        if !RbConfig::CONFIG['host_os'].match('windows')
          errors << validate_path_to_file('hostmanager.path_to_cp', @path_to_cp)
        end
        errors.compact!

        # check if aliases option is an Array
        if  !machine.config.hostmanager.aliases.kind_of?(Array) &&
            !machine.config.hostmanager.aliases.kind_of?(String)
          errors << I18n.t('vagrant_hostmanager.config.not_an_array_or_string', {
            :config_key => 'hostmanager.aliases',
            :is_class   => aliases.class.to_s,
          })
        end

        if !machine.config.hostmanager.ip_resolver.nil? &&
           !machine.config.hostmanager.ip_resolver.kind_of?(Proc)
          errors << I18n.t('vagrant_hostmanager.config.not_a_proc', {
            :config_key => 'hostmanager.ip_resolver',
            :is_class   => ip_resolver.class.to_s,
          })
        end

        errors.compact!
        { "HostManager configuration" => errors }
      end

      private

      def validate_bool(key, value)
        if ![TrueClass, FalseClass].include?(value.class) &&
           value != UNSET_VALUE
          I18n.t('vagrant_hostmanager.config.not_a_bool', {
            :config_key => key,
            :value      => value.class.to_s
          })
        else
          nil
        end
      end

      def validate_path_to_file(key, value)
        if !File.file?(value) &&
           value != UNSET_VALUE
          I18n.t('vagrant_hostmanager.config.not_a_file', {
            :config_key => key,
            :value      => value
          })
        else
          nil
        end
      end

    end
  end
end
