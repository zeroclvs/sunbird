# frozen_string_literal: true

module Sunbird
  module Render
    class Scene
      Tile = Data.define(
        :x,
        :y,
        :render_key,
        :fallback_glyph
      )

      Instance = Data.define(
        :instance_id,
        :x,
        :y,
        :render_key,
        :fallback_glyph,
        :layer
      )

      attr_reader :width, :height, :tiles, :instances

      def initialize(width:, height:, tiles:, instances:)
        @width = width
        @height = height
        @tiles = tiles.dup.freeze
        @instances = instances.dup.freeze
      end
    end
  end
end
