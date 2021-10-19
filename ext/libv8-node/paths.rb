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
      Gem::Platform.local.to_s.gsub(/-darwin-?\d+/, '-darwin')
    end

    def config
      RbConfig::MAKEFILE_CONFIG
    end

    def vendored_source_path
      File.expand_path('../../vendor/v8', __dir__)
    end
  end
end
