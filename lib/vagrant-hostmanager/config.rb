module VagrantPlugins
  module HostManager
    class Config < Vagrant.plugin('2', :config)
      attr_accessor :auto_update

      def initialize
        @auto_update = false
      end

      def validate(machine)
        errors = []
        if !(!!@auto_update == @auto_update)
          errors << 'auto_update must be a boolean' 
        end

        { 'hostmanager' => errors }
      end
    end
  end
end
