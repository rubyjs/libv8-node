# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('lib', __dir__)
require 'libv8/node/version'

Gem::Specification.new do |s|
  s.name        = 'libv8-node'
  s.version     = Libv8::Node::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['']
  s.email       = ['']
  s.homepage    = 'https://github.com/rubyjs/libv8-node'
  s.summary     = "Node.JS's V8 JavaScript engine"
  s.description = "Node.JS's V8 JavaScript engine for multiplatform goodness"
  s.license     = 'MIT'

  s.files = Dir['ext/**/*.rb'] +
            Dir['lib/**/*.rb'] +
            Dir['libexec/*'] +
            Dir['patch/*'] +
            Dir['sums/*'] +
            ['LICENSE', 'README.md', 'CHANGELOG.md']

  s.extensions = ['ext/libv8-node/extconf.rb']
  s.require_paths = ['lib', 'ext']

  s.add_development_dependency 'base64'
  s.add_development_dependency 'logger'
  s.add_development_dependency 'mutex_m'
  s.add_development_dependency 'rake', '~> 12'
  s.add_development_dependency 'rubocop', '>= 1.8.0'
  s.metadata['rubygems_mfa_required'] = 'true'
end
