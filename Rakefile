require 'bundler/setup'

Bundler::GemHelper.install_tasks

module Helpers
  module_function

  def binary_gemspec(platform: Gem::Platform.local, str: RUBY_PLATFORM)
    platform.instance_eval { @version = 'musl' } if str =~ /-musl/ && platform.version.nil?

    gemspec = eval(File.read('libv8-node.gemspec')) # rubocop:disable Security/Eval
    gemspec.platform = platform
    gemspec
  end

  def binary_gem_name(platform = Gem::Platform.local)
    File.basename(binary_gemspec(platform).cache_file)
  end
end

task :compile do
  sh 'ruby ext/libv8-node/extconf.rb'
end

task :binary, [:platform] => [:compile] do |_, args|
  gemspec = Helpers.binary_gemspec(**args.to_h)
  gemspec.extensions.clear

  # We don't need most things for the binary
  gemspec.files = []
  gemspec.files += ['lib/libv8-node.rb', 'lib/libv8/node.rb', 'lib/libv8/node/version.rb']
  gemspec.files += ['ext/libv8-node/location.rb', 'ext/libv8-node/paths.rb']
  gemspec.files += ['ext/libv8-node/.location.yml']

  # V8
  gemspec.files += Dir['vendor/v8/include/**/*.h']
  gemspec.files += Dir['vendor/v8/out.gn/**/*.a']

  FileUtils.chmod(0o0644, gemspec.files)
  FileUtils.mkdir_p('pkg')

  package = if Gem::VERSION < '2.0.0'
              Gem::Builder.new(gemspec).build
            else
              require 'rubygems/package'
              Gem::Package.build(gemspec)
            end

  FileUtils.mv(package, 'pkg')
end

namespace :binary do
  task all: :binary do
    return unless RUBY_PLATFORM =~ /darwin-?(\d+)/

    current = Integer($1)

    Helpers.binary_gemspec # loads NODE_VERSION
    major, minor = File.read(Dir["src/node-#{Libv8::Node::NODE_VERSION}/common.gypi"].last).lines.find { |l| l =~ /-mmacosx-version-min=(\d+).(\d+)/ } && [Integer($1), Integer($2)]

    first = if RUBY_PLATFORM =~ /\barm64e?-/
              20 # arm64 darwin is only available since darwin20
            elsif major == '10'
              minor + 4 # macos 10.X => darwinY offset, 10.15 is darwin19
            else
              minor + 20 # maxos 11.X => darwinY offset, 11.0 is darwin20
            end
    max = 20 # current known max to build for

    (first..max).each do |version|
      next if version == current

      platform = Gem::Platform.local.dup
      platform.instance_eval { @version = version }
      puts "> building #{platform}"

      Rake::Task['binary'].execute(Rake::TaskArguments.new([:platform], [platform]))
    end
  end
end
