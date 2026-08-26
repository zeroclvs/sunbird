# frozen_string_literal: true

module Sunbird
  class World
    Identity = Data.define(:entity)
    Position = Data.define(:x, :y)
    Health = Data.define(:current, :max)
    Renderable = Data.define(:glyph, :layer)
    Behavior = Data.define(:kind)
    Collision = Data.define(:blocks_movement)
  end
end
