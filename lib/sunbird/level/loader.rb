# frozen_string_literal: true

module Sunbird
  module Level
    module Loader
      module_function

      def load(path, entities:)
        absolute_path = File.expand_path(path)

        unless File.extname(absolute_path) == ".rb"
          raise ArgumentError,
            "unsupported level source: #{absolute_path}"
        end

        require absolute_path

        source_name = constant_name_for(absolute_path)
        definition = Sources.const_get(
          source_name,
          false
        )

        map = Map.new(
          rows: definition.rows,
          tiles: definition.tiles
        )

        validate_spawns!(
          map,
          definition.spawns,
          entities
        )

        Loaded.new(
          map: map,
          spawns: definition.spawns
        )
      end

      def constant_name_for(path)
        File.basename(path, ".rb")
          .split("_")
          .map!(&:capitalize)
          .join
      end
      private_class_method :constant_name_for

      def validate_spawns!(map, spawns, entities)
        spawns.each do |spawn|
          entities.fetch(spawn.entity)

          unless map.inside?(spawn.x, spawn.y)
            raise ArgumentError,
              "#{spawn.entity} spawn is outside the map " \
              "at (#{spawn.x}, #{spawn.y})"
          end

          next if map.passable?(spawn.x, spawn.y)

          raise ArgumentError,
            "#{spawn.entity} spawn is on blocked terrain " \
            "at (#{spawn.x}, #{spawn.y})"
        end
      end
      private_class_method :validate_spawns!
    end
  end
end
