module VagrantPlugins
  module HostManager
    class Config < Vagrant.plugin('2', :config)
      attr_accessor :enabled
      attr_accessor :manage_local
      attr_accessor :ignore_private_ip
      attr_accessor :aliases

      alias_method :enabled?, :enabled

      def initialize
        @enabled = false
        @manage_local = true
        @ignore_private_ip = UNSET_VALUE
        @aliases = Array.new
      end

      def finalize!
        @ignore_private_ip = false if @ignore_private_ip == UNSET_VALUE
      end

      def validate(machine)
        errors = Array.new

        # check if enabled option is either true or false
        if ![TrueClass, FalseClass].include?(enabled.class)
          errors << "A value for hostmanager.enabled can be true or false."
        end

        # check if manage_local option is either true or false
        if ![TrueClass, FalseClass].include?(manage_local.class)
          errors << "A value for hostmanager.manage_local can be true or false."
        end

        # check if ignore_private_ip option is either true or false
        if ![TrueClass, FalseClass].include?(ignore_private_ip.class) &&
          @ignore_private_ip != UNSET_VALUE
          errors << "A value for hostmanager.ignore_private_ip can be true or false."
        end

        # check if aliases option is an Array
        if !machine.config.hostmanager.aliases.kind_of?(Array)
          errors << "A value for hostmanager.aliases must be an Array."
        end

        { "HostManager configuration" => errors }
      end
    end
  end
end
