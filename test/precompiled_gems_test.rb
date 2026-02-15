# frozen_string_literal: true

require "test_helper"
require "debug"
require "open3"

class PrecompiledGemsTest < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir

    super
  end

  def teardown
    super

    FileUtils.rm_rf(@tmpdir)
  end

  def test_direct_dependency
    File.write("#{@tmpdir}/Gemfile", <<~RUBY)
      source "https://rubygems.org"

      plugin "precompiled_gems", path: "#{File.expand_path("..", __dir__)}"
      if Bundler::Plugin.installed?('precompiled_gems')
        Plugin.send(:load_plugin, 'precompiled_gems')

        use_precompiled_gems!
      end

      gem 'bigdecimal'
    RUBY

    Bundler.original_system(
      { "BUNDLE_PATH" => @tmpdir, "BUNDLE_GEMFILE" => "#{@tmpdir}/Gemfile" },
      "bundle install > /dev/null"
    )

    definition = Bundler::Definition.build("#{@tmpdir}/Gemfile", "#{@tmpdir}/Gemfile.lock", nil)
    locked_deps = definition.locked_deps.keys

    assert_equal(["ed-precompiled_bigdecimal"], locked_deps)
  end

  def test_transitive_dependencies
    File.write("#{@tmpdir}/Gemfile", <<~RUBY)
      source "https://rubygems.org"

      plugin "precompiled_gems", path: "#{File.expand_path("..", __dir__)}"
      if Bundler::Plugin.installed?('precompiled_gems')
        Plugin.send(:load_plugin, 'precompiled_gems')

        use_precompiled_gems!
      end

      gem 'cel'
    RUBY

    Bundler.original_system(
      { "BUNDLE_PATH" => @tmpdir, "BUNDLE_GEMFILE" => "#{@tmpdir}/Gemfile" },
      "bundle install > /dev/null"
    )

    definition = Bundler::Definition.build("#{@tmpdir}/Gemfile", "#{@tmpdir}/Gemfile.lock", nil)
    locked_specs = definition.locked_gems.specs.map(&:name)

    assert_includes(locked_specs, "ed-precompiled_bigdecimal")
    refute_includes(locked_specs, "bigdecimal")
  end

  def test_use_custom_precompiled_gems
    File.write("#{@tmpdir}/Gemfile", <<~RUBY)
      source "https://rubygems.org"

      plugin "precompiled_gems", path: "#{File.expand_path("..", __dir__)}"
      if Bundler::Plugin.installed?('precompiled_gems')
        Plugin.send(:load_plugin, 'precompiled_gems')

        use_precompiled_gems!("digest-crc" => "precompiled-digest-crc")
      end

      gem 'digest-crc'
    RUBY

    Bundler.original_system(
      { "BUNDLE_PATH" => @tmpdir, "BUNDLE_GEMFILE" => "#{@tmpdir}/Gemfile" },
      "bundle install > /dev/null"
    )

    definition = Bundler::Definition.build("#{@tmpdir}/Gemfile", "#{@tmpdir}/Gemfile.lock", nil)
    locked_deps = definition.locked_deps.keys

    assert_includes(locked_deps, "precompiled-digest-crc")
    refute_includes(locked_deps, "digest-crc")
  end

  def test_activates_gem
    File.write("#{@tmpdir}/Gemfile", <<~RUBY)
      source "https://rubygems.org"

      plugin "precompiled_gems", path: "#{File.expand_path("..", __dir__)}"
      if Bundler::Plugin.installed?('precompiled_gems')
        Plugin.send(:load_plugin, 'precompiled_gems')

        use_precompiled_gems!
      end

      gem 'cel'
    RUBY

    Bundler.original_system(
      { "BUNDLE_PATH" => @tmpdir, "BUNDLE_GEMFILE" => "#{@tmpdir}/Gemfile" },
      "bundle install > /dev/null"
    )

    File.write("#{@tmpdir}/script.rb", <<~RUBY)
      #!#{RbConfig.ruby}

      gem 'bigdecimal'
      require 'bigdecimal'

      puts $LOADED_FEATURES.grep /bigdecimal/
    RUBY

    FileUtils.chmod("+x", "#{@tmpdir}/script.rb")

    Bundler.with_original_env do
      out, status = Open3.capture2e(
        { "BUNDLE_PATH" => @tmpdir, "BUNDLE_GEMFILE" => "#{@tmpdir}/Gemfile" },
        "bundle exec #{@tmpdir}/script.rb"
      )

      flunk("Command failed") unless status.success?

      out.each_line do |line|
        assert(line.match?(%r{gems/ed-precompiled_bigdecimal-}))
      end
    end
  end

  def test_bundle_clean
    File.write("#{@tmpdir}/Gemfile", <<~RUBY)
      source "https://rubygems.org"

      plugin "precompiled_gems", path: "#{File.expand_path("..", __dir__)}"
      if Bundler::Plugin.installed?('precompiled_gems')
        Plugin.send(:load_plugin, 'precompiled_gems')

        use_precompiled_gems!
      end

      gem 'rubocop'
    RUBY

    Bundler.original_system(
      { "BUNDLE_PATH" => @tmpdir, "BUNDLE_GEMFILE" => "#{@tmpdir}/Gemfile" },
      "bundle install > /dev/null"
    )

    Bundler.original_system(
      { "BUNDLE_PATH" => @tmpdir, "BUNDLE_GEMFILE" => "#{@tmpdir}/Gemfile", "BUNDLE_CLEAN" => "1" },
      "bundle install > /dev/null"
    )

    assert(File.exist?("#{@tmpdir}/ruby/3.4.0/bin/rubocop"))
  end
end
