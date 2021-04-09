unless $LOAD_PATH.include?(File.expand_path('../../lib', __dir__))
  $LOAD_PATH.unshift(File.expand_path('../../lib', __dir__))
end
require 'libv8/node/version'

module Libv8::Node
  class BuilderError < StandardError; end

  class Builder
    def build_libv8!
      version = Libv8::Node::NODE_VERSION
      download_node(version)  || raise(BuilderError, "failed to download node #{NODE_VERSION}")
      extract_node(version)   || raise(BuilderError, "failed to extract node #{NODE_VERSION}")
      build_libv8(version)    || raise(BuilderError, "failed to build libv8 #{NODE_VERSION}")
      build_monolith(version) || raise(BuilderError, "failed to build monolith #{NODE_VERSION}")
      inject_libv8(version)   || raise(BuilderError, "failed to inject libv8 #{NODE_VERSION}")

      0
    end

    def remove_intermediates!
      FileUtils.rm_rf(File.expand_path('../../src', __dir__))
    end

    private

    def download_node(version)
      system(script('download-node'), version)
    end

    def extract_node(version)
      system(script('extract-node'), version)
    end

    def build_libv8(version)
      system(script('build-libv8'), version)
    end

    def build_monolith(version)
      system(script('build-monolith'), version)
    end

    def inject_libv8(version)
      system(script('inject-libv8'), version)
    end

    def script(name)
      File.expand_path("../../libexec/#{name}", __dir__).tap do |v|
        puts "==== in #{Dir.pwd}"
        puts "==== running #{v}"
      end
    end
  end
end
