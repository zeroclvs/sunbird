# frozen_string_literal: true

module Sunbird
  class World
    EntityRef = Data.define(:name)
    Position = Data.define(:x, :y)
    Health = Data.define(:current, :max)
    Renderable = Data.define(:glyph, :layer)
    Behavior = Data.define(:kind)
    Collision = Data.define(:blocks_movement)
  end
end
