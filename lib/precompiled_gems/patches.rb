# frozen_string_literal: true

require "bundler"

module PrecompiledGems
  module DslPatch
    def use_precompiled_gems!(gems = {})
      PrecompiledGems.enabled = true
      PrecompiledGems.gems.merge!(gems)
    end

    def gem(name, *args)
      super(PrecompiledGems.takeover(name), *args)
    end
  end

  module CompactIndexClientPatch
    def info(name)
      super(PrecompiledGems.takeover(name))
    end
  end

  module EndpointSpecificationPatch
    def build_dependency(name, *args)
      super(PrecompiledGems.takeover(name), *args)
    end
  end

  module SharedHelpersPatch
    def ensure_same_dependencies(*)
      # No-op. Will figure this out later.
    end
  end

  module KernelPatch
    def self.included(kernel)
      kernel.class_eval do
        def new_gem(name, *args)
          old_gem(PrecompiledGems.takeover(name), *args)
        end
        alias old_gem gem
        alias gem new_gem
      end
    end
  end

  module RubygemsIntegrationPatch
    def installed_specs
      super.each do |spec|
        spec.runtime_dependencies.each do |dep|
          dep.name = PrecompiledGems.takeover(dep.name)
        end
      end
    end

    def replace_gem(*)
      super

      Kernel.include(KernelPatch)
    end
  end
end

Bundler::Dsl.prepend(PrecompiledGems::DslPatch)
Bundler::CompactIndexClient.prepend(PrecompiledGems::CompactIndexClientPatch)
Bundler::EndpointSpecification.prepend(PrecompiledGems::EndpointSpecificationPatch)
Bundler::SharedHelpers.singleton_class.prepend(PrecompiledGems::SharedHelpersPatch)
Bundler::RubygemsIntegration.prepend(PrecompiledGems::RubygemsIntegrationPatch)
