# frozen_string_literal: true

module PrecompiledGems
  module DslPatch
    def precompiled_gems!
      PrecompiledGems.enabled = true
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
end

Bundler::Dsl.prepend(PrecompiledGems::DslPatch)
Bundler::CompactIndexClient.prepend(PrecompiledGems::CompactIndexClientPatch)
Bundler::EndpointSpecification.prepend(PrecompiledGems::EndpointSpecificationPatch)
Bundler::SharedHelpers.singleton_class.prepend(PrecompiledGems::SharedHelpersPatch)
