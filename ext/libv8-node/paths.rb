# frozen_string_literal: true

require 'rbconfig'
require 'shellwords'

module Libv8; end

module Libv8::Node
  module Paths
    module_function

    def include_paths
      [Shellwords.escape(File.join(vendored_source_path, 'include'))]
    end

    def object_paths
      [Shellwords.escape(File.join(vendored_source_path,
                                   platform,
                                   'libv8',
                                   'obj',
                                   "libv8_monolith.#{config['LIBEXT']}"))]
    end

    def platform
      @platform ||= begin
        local = Gem::Platform.local
        parts = [local.cpu, local.os, local.version]
        parts[2] = 'musl' if RUBY_PLATFORM =~ /musl/
        ideal = parts.compact.reject { |s| s.to_s.empty? }.join('-').gsub(/-darwin-?\d+/, '-darwin')

        return ideal if File.directory?(File.join(vendored_source_path, ideal))

        available = Dir.glob(File.join(vendored_source_path, '*')).select { |d| File.directory?(d) }.map { |d| File.basename(d) } - ['include']
        available.size == 1 ? available.first : ideal
      end
    end

    def config
      RbConfig::MAKEFILE_CONFIG
    end

    def vendored_source_path
      File.expand_path('../../vendor/v8', __dir__)
    end
  end
end
