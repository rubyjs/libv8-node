require 'libv8_node/version'
require 'libv8-node/location'

module Libv8Node
  def self.configure_makefile
    location = Location.load!
    location.configure
  end
end

