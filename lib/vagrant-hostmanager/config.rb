module VagrantPlugins
  module HostManager
    class Config < Vagrant.plugin('2', :config)
      attr_accessor :enabled
      attr_accessor :manage_host
      attr_accessor :ignore_private_ip
      attr_accessor :aliases
      attr_accessor :aliases_only
      attr_accessor :include_offline

      alias_method :enabled?, :enabled
      alias_method :include_offline?, :include_offline
      alias_method :manage_host?, :manage_host

      def initialize
        @enabled = false
        @manage_host = UNSET_VALUE
        @ignore_private_ip = UNSET_VALUE
        @include_offline = UNSET_VALUE
        @aliases = []
        @aliases_only = UNSET_VALUE
      end

      def finalize!
        @manage_host = false if @manage_host == UNSET_VALUE
        @ignore_private_ip = false if @ignore_private_ip == UNSET_VALUE
        @include_offline = false if @include_offline == UNSET_VALUE
        @aliases = [ @aliases ].flatten
        @aliases_only = false if @aliases_only == UNSET_VALUE
      end

      def validate(machine)
        errors = []

        errors << validate_bool('hostmanager.aliases_only', @aliases_only)
        errors << validate_bool('hostmanager.enabled', @enabled)
        errors << validate_bool('hostmanager.manage_host', @manage_host)
        errors << validate_bool('hostmanager.ignore_private_ip', @ignore_private_ip)
        errors << validate_bool('hostmanager.include_offline', @include_offline)
        errors.compact!

        if !machine.config.hostmanager.aliases.kind_of?(Array) and
            !machine.config.hostmanager.aliases.kind_of?(String)
          errors << I18n.t('vagrant_hostmanager.config.not_an_array_or_string', {
            :config_key => 'hostmanager.aliases',
            :is_class   => aliases.class.to_s,
          })
        end

        if machine.config.hostmanager.aliases_only && machine.config.hostmanager.aliases.empty?
          errors << I18n.t('vagrant_hostmanager.config.aliases_required')
        end

        { 'HostManager configuration' => errors }
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
    end
  end
end
