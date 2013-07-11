module VagrantPlugins
  module HostManager
    class Config < Vagrant.plugin('2', :config)
      attr_accessor :enabled
      attr_accessor :manage_host
      attr_accessor :ignore_private_ip
      attr_accessor :aliases
      attr_accessor :include_offline

      alias_method :enabled?, :enabled
      alias_method :include_offline?, :include_offline
      alias_method :manage_host?, :manage_host

      def initialize
        @enabled = UNSET_VALUE
        @manage_host = UNSET_VALUE
        @ignore_private_ip = UNSET_VALUE
        @include_offline = UNSET_VALUE
        @aliases = []
      end

      def validate(machine)
        @enabled = false if @enabled == UNSET_VALUE
        @manage_host = false if @manage_host == UNSET_VALUE
        @ignore_private_ip = false if @ignore_private_ip == UNSET_VALUE
        @include_offline = false if @include_offline == UNSET_VALUE
        @aliases = [ @aliases ].flatten

        errors = []

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

        { 'HostManager configuration' => errors }
      end

      private

      def validate_bool(key, value)
        if ![TrueClass, FalseClass].include?(value.class)
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
