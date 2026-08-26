# frozen_string_literal: true

module Sunbird
  module Level
    Tile = Data.define(:glyph, :passable)

    Spawn = Data.define(
      :entity,
      :x,
      :y
    )

    Definition = Data.define(
      :name,
      :tiles,
      :rows,
      :spawns
    )

    Loaded = Data.define(
      :map,
      :spawns
    )

    module Sources
    end
  end
end
