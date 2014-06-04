module VagrantPlugins
  module HostManager
    class Config < Vagrant.plugin('2', :config)
      attr_accessor :enabled
      attr_accessor :manage_host
      attr_accessor :ignore_private_ip
      attr_accessor :aliases
      attr_accessor :alias_rows
      attr_accessor :include_offline
      attr_accessor :ip_resolver

      alias_method :enabled?, :enabled
      alias_method :include_offline?, :include_offline
      alias_method :manage_host?, :manage_host

      def initialize
        @enabled            = UNSET_VALUE
        @manage_host        = UNSET_VALUE
        @ignore_private_ip  = UNSET_VALUE
        @include_offline    = UNSET_VALUE
        @aliases            = UNSET_VALUE
        @alias_rows         = UNSET_VALUE
        @ip_resolver        = UNSET_VALUE
      end

      def finalize!
        @enabled            = false if @enabled == UNSET_VALUE
        @manage_host        = false if @manage_host == UNSET_VALUE
        @ignore_private_ip  = false if @ignore_private_ip == UNSET_VALUE
        @include_offline    = false if @include_offline == UNSET_VALUE
        @aliases            = [] if @aliases == UNSET_VALUE
        @alias_rows         = [] if @alias_rows == UNSET_VALUE
        @ip_resolver        = nil if @ip_resolver == UNSET_VALUE

        @aliases = [ @aliases ].flatten
      end

      def validate(machine)
        errors = []

        errors << validate_bool('hostmanager.enabled', @enabled)
        errors << validate_bool('hostmanager.manage_host', @manage_host)
        errors << validate_bool('hostmanager.ignore_private_ip', @ignore_private_ip)
        errors << validate_bool('hostmanager.include_offline', @include_offline)
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

        if !machine.config.hostmanager.alias_rows.nil?
          machine.config.hostmanager.alias_rows.each { |row|
            if !row[0].kind_of?(String)
              errors << I18n.t('vagrant_hostmanager.config.not_a_string', {
                :config_key => 'first parameter of hostmanager.alias_rows',
                :is_class   => row[0].class.to_s,
              })
            end

            if !row[1].kind_of?(Hash)
              errors << I18n.t('vagrant_hostmanager.config.not_a_hash', {
                :config_key => 'second parameter of hostmanager.alias_rows',
                :is_class   => row[1].class.to_s,
              })
            end
          }
        end

        errors.compact!
        { "HostManager configuration" => errors }
      end

      def alias(hostname, options = {})
        @alias_rows = [] if @alias_rows == UNSET_VALUE
        @alias_rows << [hostname, options]
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
