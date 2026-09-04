# frozen_string_literal: true

module Sunbird
  module Render
    class Ascii
      def render(scene)
        cells = Array.new(scene.height) do
          Array.new(scene.width, " ")
        end

        scene.tiles.each do |tile|
          cells[tile.y][tile.x] = tile.fallback_glyph
        end

        scene.instances.sort_by(&:layer).each do |instance|
          cells[instance.y][instance.x] = instance.fallback_glyph
        end

        cells.map(&:join).join("\n")
      end
    end
  end
end
