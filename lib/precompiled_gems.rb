# frozen_string_literal: true

require_relative "precompiled_gems/version"
require_relative "precompiled_gems/dsl_patch"

module PrecompiledGems
  extend self

  def list
    {
      "bigdecimal" => "ed-precompiled_bigdecimal",
    }
  end
end
