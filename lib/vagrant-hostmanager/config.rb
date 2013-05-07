module VagrantPlugins
  module HostManager
    class Config < Vagrant.plugin('2', :config)
      attr_accessor :enabled
      attr_accessor :ignore_private_ip
      attr_accessor :aliases
      attr_accessor :include_offline

      alias_method :enabled?, :enabled
      alias_method :include_offline?, :include_offline

      def initialize
        @enabled = false
        @ignore_private_ip = UNSET_VALUE
        @aliases = Array.new
        @include_offline = false
      end

      def finalize!
        @ignore_private_ip = false if @ignore_private_ip == UNSET_VALUE
        @aliases = [ @aliases ].flatten
      end

      def validate(machine)
        errors = Array.new

        # check if enabled option is either true or false
        errors << validate_bool('hostmanager.enabled', enabled)

        # check if include_offline is either true or false
        errors << validate_bool('hostmanager.include_offline', include_offline)

        # check if ignore_private_ip option is either true or false (or UNSET_VALUE)
        if @ignore_private_ip != UNSET_VALUE
          errors << validate_bool('hostmanager.ignore_private_ip', ignore_private_ip)
        end

        # check if aliases option is an Array
        if  !machine.config.hostmanager.aliases.kind_of?(Array) and
            !machine.config.hostmanager.aliases.kind_of?(String)
          errors << I18n.t('vagrant_hostmanager.config.not_an_array_or_string', {
            :config_key => 'hostmanager.aliases',
            :is_class   => aliases.class.to_s,
          })
        end

        errors.compact!
        { "HostManager configuration" => errors }
      end

      private
      def validate_bool(key, value)
        if ![TrueClass, FalseClass].include?(value.class)
          I18n.t('vagrant_hostmanager.config.not_a_bool', {
            :config_key => key,
            :value      => value.class.to_s,
          })
        else
          nil
        end
      end

    end
  end
end
