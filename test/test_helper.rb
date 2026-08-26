# frozen_string_literal: true

require "minitest/autorun"

$LOAD_PATH.unshift(
  File.expand_path("../lib", __dir__)
)

require "sunbird"

module SunbirdTestPaths
  ENTITY_PATH = File.expand_path(
    "../content/entities/core.rb",
    __dir__
  )

  LEVEL_PATH = File.expand_path(
    "../content/levels/test_field.rb",
    __dir__
  )
end
