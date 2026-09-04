# frozen_string_literal: true

module Sunbird
  class Level
    Tile = Data.define(
      :render_key,
      :glyph,
      :passable
    )

    Spawn = Data.define(
      :key,
      :entity,
      :x,
      :y
    )

    Relation = Data.define(
      :kind,
      :source,
      :target
    )

    Definition = Data.define(
      :name,
      :tiles,
      :rows,
      :spawns,
      :relations,
      :controlled_spawn
    )

    module Definitions
    end

    attr_reader :name,
      :terrain,
      :spawns,
      :relations,
      :controlled_spawn

    def initialize(
      name:,
      terrain:,
      spawns:,
      relations:,
      controlled_spawn:
    )
      @name = name
      @terrain = terrain
      @spawns = spawns.dup.freeze
      @relations = relations.dup.freeze
      @controlled_spawn = controlled_spawn
    end

    def width
      terrain.width
    end

    def height
      terrain.height
    end

    def inside?(x, y)
      terrain.inside?(x, y)
    end

    def glyph_at(x, y)
      terrain.glyph_at(x, y)
    end

    def render_key_at(x, y)
      terrain.render_key_at(x, y)
    end

    def passable?(x, y)
      terrain.passable?(x, y)
    end
  end
end
