# frozen_string_literal: true

module Sunbird
  module Render
    class Projector
      def project(level:, world:)
        cells = Array.new(level.height) do |y|
          Array.new(level.width) do |x|
            level.glyph_at(x, y)
          end
        end

        renderables(world).each do |
          _instance_id,
          position,
          renderable
        |
          next unless level.inside?(
            position.x,
            position.y
          )

          cells[position.y][position.x] =
            renderable.glyph
        end

        lines = cells.map do |row|
          row.join.freeze
        end.freeze

        Frame.new(lines: lines)
      end

      private

      def renderables(world)
        world.instance_ids.filter_map do |instance_id|
          position = world.component(
            instance_id,
            :position
          )

          renderable = world.component(
            instance_id,
            :renderable
          )

          next unless position && renderable

          [
            instance_id,
            position,
            renderable
          ]
        end.sort_by do |
          _instance_id,
          _position,
          renderable
        |
          renderable.layer
        end
      end
    end
  end
end
