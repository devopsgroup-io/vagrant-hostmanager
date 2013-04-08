module VagrantPlugins
  module HostManager
    class Config < Vagrant.plugin('2', :config)
      attr_accessor :auto_update
      attr_accessor :ignore_private_ip

      def initialize
        @auto_update = UNSET_VALUE
        @ignore_private_ip = UNSET_VALUE
      end

      def finalize!
        @auto_update = true if @auto_update == UNSET_VALUE
        @ignore_private_ip = false if @ignore_private_ip == UNSET_VALUE
      end
    end
  end
end
