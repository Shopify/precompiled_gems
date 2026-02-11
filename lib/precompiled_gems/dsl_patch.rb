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
end

Bundler::Dsl.prepend(PrecompiledGems::DslPatch)
