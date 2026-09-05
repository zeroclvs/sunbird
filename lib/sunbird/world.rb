# frozen_string_literal: true

require_relative "area_state/components"
require_relative "area_state/component_table"
require_relative "area_state/relations"
require_relative "area_state/view"
require_relative "area_state"

module Sunbird
  World = AreaState unless const_defined?(:World, false)
end
