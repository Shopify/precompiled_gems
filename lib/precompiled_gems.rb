# frozen_string_literal: true

require_relative "precompiled_gems/version"
require_relative "precompiled_gems/patches"

module PrecompiledGems
  extend self

  attr_accessor :enabled
  self.enabled = false

  def takeover(original_gem)
    return original_gem unless enabled

    return list.fetch(original_gem, original_gem)
  end

  def list
    {
      "bigdecimal" => "ed-precompiled_bigdecimal",
    }
  end
end
