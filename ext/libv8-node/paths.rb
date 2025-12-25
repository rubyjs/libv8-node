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
      @platform ||= determine_platform
    end

    def determine_platform
      ideal = construct_ideal_platform_name
      return ideal if platform_directory_exists?(ideal)

      fallback_platform
    end

    def construct_ideal_platform_name
      local = Gem::Platform.local
      parts = [local.cpu, local.os, local.version]
      parts[2] = 'musl' if musl_platform?
      parts.compact.reject(&:empty?).join('-').gsub(/-darwin-?\d+/, '-darwin')
    end

    def musl_platform?
      RUBY_PLATFORM =~ /musl/
    end

    def platform_directory_exists?(name)
      File.directory?(File.join(vendored_source_path, name))
    end

    def fallback_platform
      available = available_platform_directories
      available.size == 1 ? available.first : construct_ideal_platform_name
    end

    def available_platform_directories
      Dir.glob(File.join(vendored_source_path, '*')).select { |d| File.directory?(d) }.map { |d| File.basename(d) } - ['include']
    end

    def config
      RbConfig::MAKEFILE_CONFIG
    end

    def vendored_source_path
      File.expand_path('../../vendor/v8', __dir__)
    end
  end
end
