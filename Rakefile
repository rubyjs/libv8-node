# frozen_string_literal: true

require 'bundler/setup'

Bundler::GemHelper.install_tasks

module Helpers
  module_function

  def binary_gemspec(platform: Gem::Platform.local, str: RUBY_PLATFORM)
    # TODO: old rubygems and cross compile
    platform.instance_eval { @version = 'musl' } if str =~ /-musl/ && platform.version.nil?

    gemspec = eval(File.read('libv8-node.gemspec')) # rubocop:disable Security/Eval
    gemspec.platform = platform
    gemspec
  end

  def binary_gem_name(platform = Gem::Platform.local)
    File.basename(binary_gemspec(platform).cache_file)
  end
end

task :compile, [:platform] => [] do |_, args|
  local_platform = Gem::Platform.local
  target_platform = Gem::Platform.new(ENV['RUBY_TARGET_PLATFORM'] || args.to_h[:platform] || Gem::Platform.local)

  target_platform.instance_eval { @version = nil } if target_platform.os == 'darwin'

  puts "local platform: #{local_platform}"
  puts "target platform: #{target_platform}"

  ENV['RUBY_TARGET_PLATFORM'] = target_platform.to_s

  if (libs = Dir["vendor/v8/#{target_platform}/**/*.a"]).any?
    puts "found: #{libs.inspect}"
    next
  end

  Dir.chdir('ext/libv8-node') do # gem install behaves like that
    sh 'ruby extconf.rb'
  end
end

task :binary, [:platform] => [:compile] do |_, args|
  local_platform = Gem::Platform.local.dup
  target_platform = Gem::Platform.new(ENV['RUBY_TARGET_PLATFORM'] || args.to_h[:platform] || Gem::Platform.local)

  target_platform.instance_eval { @version = nil } if target_platform.os == 'darwin'

  puts "local platform: #{local_platform}"
  puts "target platform: #{target_platform}"
  gemspec = Helpers.binary_gemspec(platform: target_platform)
  gemspec.extensions.clear

  # We don't need most things for the binary
  gemspec.files = []
  gemspec.files += ['lib/libv8-node.rb', 'lib/libv8/node.rb', 'lib/libv8/node/version.rb']
  gemspec.files += ['ext/libv8-node/location.rb', 'ext/libv8-node/paths.rb']
  gemspec.files += ['ext/libv8-node/.location.yml']

  # V8
  gemspec.files += Dir['vendor/v8/include/**/*.h']
  gemspec.files += Dir["vendor/v8/#{target_platform}/**/*.a"]

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

desc 'Fetch gems from a GitHub Actions run URL'
task :fetch_gems, [:url] do |_, args|
  url = args[:url] || ENV['URL']
  abort 'Usage: rake fetch_gems[url]' unless url
  sh "libexec/fetch-gems #{url}"
end
