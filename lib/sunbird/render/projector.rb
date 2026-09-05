# frozen_string_literal: true

module Sunbird
  module Render
    class Projector
      def project(level:, area: nil, world: nil)
        area ||= world

        unless area
          raise ArgumentError,
            "Render::Projector requires an area view"
        end

        Scene.new(
          width: level.width,
          height: level.height,
          tiles: project_tiles(level),
          instances: project_instances(level, area)
        )
      end

      private

      def project_tiles(level)
        Array.new(level.height) do |y|
          Array.new(level.width) do |x|
            Scene::Tile.new(
              x: x,
              y: y,
              render_key: level.render_key_at(x, y),
              fallback_glyph: level.glyph_at(x, y)
            )
          end
        end.flatten.freeze
      end

      def project_instances(level, area)
        renderables(area).filter_map do |
          instance_id,
          position,
          renderable
        |
          next unless level.inside?(
            position.x,
            position.y
          )

          Scene::Instance.new(
            instance_id: instance_id,
            x: position.x,
            y: position.y,
            render_key: renderable.render_key,
            fallback_glyph: renderable.glyph,
            layer: renderable.layer
          )
        end.freeze
      end

      def renderables(area)
        area.instance_ids.filter_map do |instance_id|
          position = area.component(
            instance_id,
            :position
          )
          renderable = area.component(
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
