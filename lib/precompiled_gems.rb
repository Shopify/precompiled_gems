# frozen_string_literal: true

require_relative "precompiled_gems/version"
require_relative "precompiled_gems/patches"

module PrecompiledGems
  extend self

  attr_accessor :gems
  self.gems = {
    "bigdecimal" => "ed-precompiled_bigdecimal",
    "websocket-driver" => "ed3-precompiled_websocket-driver",
    "prism" => "ed-precompiled_prism",
    "nio4r" => "ed-precompiled_nio4r",
    "erb" => "ed-precompiled_erb",
    "racc" => "ed-precompiled_racc",
    "date" => "ed-precompiled_date",
    "stringio" => "ed-precompiled_stringio",
    "json" => "ed-precompiled_json",
    "io-console" => "ed-precompiled_io-console",
    "bootsnap" => "ed-precompiled_bootsnap",
    "puma" => "ed2-precompiled_puma",
    "bindex" => "ed-precompiled_bindex",
    "msgpack" => "ed-precompiled_msgpack",
    "debug" => "ed2-precompiled_debug",
    "bcrypt_pbkdf" => "ed-precompiled_bcrypt_pbkdf",
    "ed25519" => "ed-precompiled_ed25519",
  }
  attr_accessor :enabled
  self.enabled = false

  def takeover(original_gem)
    return original_gem unless enabled

    gems.fetch(original_gem, original_gem)
  end
end
