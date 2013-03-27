require 'vagrant'
require 'vagrant-hostmanager/plugin'
require 'vagrant-hostmanager/version'
require 'vagrant-hostmanager/errors'

module VagrantPlugins
  module HostManager
    def self.source_root
      @source_root ||= Pathname.new(File.expand_path('../../', __FILE__))
    end
  end
end
