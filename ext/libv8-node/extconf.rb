# frozen_string_literal: true

require 'mkmf'

if RUBY_ENGINE == 'truffleruby'
  File.write('Makefile', dummy_makefile($srcdir).join('')) # rubocop:disable Style/GlobalVars
  return
end

create_makefile('libv8-node')

require File.expand_path('location', __dir__)
location = Libv8::Node::Location::Vendor.new

exit location.install!
