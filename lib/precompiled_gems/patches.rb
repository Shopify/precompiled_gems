# frozen_string_literal: true

module PrecompiledGems
  module DslPatch
    def initialize
      @target_precompiled_gems = false

      super
    end

    def precompiled_gems!
      @target_precompiled_gems = true
    end

    def gem(name, *args)
      if @target_precompiled_gems && PrecompiledGems.list.key?(name)
        name = PrecompiledGems.list.fetch(name)
      end

      super
    end
  end

  module CompactIndexClientPatch
    def info(name)
      name = "ed-precompiled_bigdecimal" if name == "bigdecimal"

      super
    end
  end

  module EndpointSpecificationPatch
    def build_dependency(name, *)
      name = "ed-precompiled_bigdecimal" if name == "bigdecimal"

      super
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
