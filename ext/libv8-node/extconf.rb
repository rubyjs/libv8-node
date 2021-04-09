# frozen_string_literal: true

require 'mkmf'
create_makefile('libv8-node')

require File.expand_path('location', __dir__)
location = Libv8::Node::Location::Vendor.new

exit location.install!
