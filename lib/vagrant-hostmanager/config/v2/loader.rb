require 'vagrant/config/v2/loader'

# if a given key doesn't exist for a VM configuration (config.vm.define block)
# then no merge will be attempted between the global config and the VM config,
# and the global will take effect.  For many (most?) configuration this is the
# desired behaviour, except for the hosts configuration.
# This hack is to ensure that there is VM configuration always so that global
# hosts entries aren't presented as VM hosts entries

module Vagrant
  module Config
    module V2
      class Loader
        class << self
          alias_method :orig_new_root_object, :new_root_object
          def new_root_object
            # we're making sure that the config has a hostmanager key/value
            # to avoid the leakage of the global hostmanager config
            orig_new_root_object.tap {|c| c.hostmanager }
          end
        end
      end
    end
  end
end

