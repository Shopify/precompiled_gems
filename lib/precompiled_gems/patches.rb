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

  module KernelGemPatch
    def gem(name, *args)
      super(PrecompiledGems.takeover(name), *args)
    end
  end
end

Bundler::Dsl.prepend(PrecompiledGems::DslPatch)
Bundler::CompactIndexClient.prepend(PrecompiledGems::CompactIndexClientPatch)
Bundler::EndpointSpecification.prepend(PrecompiledGems::EndpointSpecificationPatch)
Bundler::SharedHelpers.singleton_class.prepend(PrecompiledGems::SharedHelpersPatch)
Kernel.prepend(PrecompiledGems::KernelGemPatch)
