module VagrantPlugins
  module HostManager
    class Config < Vagrant.plugin('2', :config)
      attr_accessor :auto_update
      attr_accessor :ignore_private_ip
      attr_accessor :aliases

      def initialize
        @auto_update = UNSET_VALUE
        @ignore_private_ip = UNSET_VALUE
        @aliases = Array.new 
      end

      def finalize!
        @auto_update = true if @auto_update == UNSET_VALUE
        @ignore_private_ip = false if @ignore_private_ip == UNSET_VALUE
      end

      def validate(machine)
        errors = Array.new

        # check if auto_update option is defined in Vagrantfile
        # and check if is either true or false accordingly
        if (machine.config.hostmanager.auto_update &&
            ![TrueClass, FalseClass].include?(auto_update.class))
          errors << "A value for hostmanager.auto_update can be true or false."
        end

        # check if ignore_private_ip option is defined in Vagrantfile
        # and check if is either true or false accordingly
        if (machine.config.hostmanager.ignore_private_ip &&
            ![TrueClass, FalseClass].include?(ignore_private_ip.class))
          errors << "A value for hostmanager.ignore_private_ip can be true or false."
        end

        # check if aliases option is defined in Vagrantfile
        # and check if is an Array accordingly
        if (machine.config.hostmanager.aliases &&
            !machine.config.hostmanager.aliases.kind_of?(Array))
          errors << "A value for hostmanager.aliases must be an Array."
        end
        
        { "HostManager configuration" => errors }
      end
    end
  end
end
