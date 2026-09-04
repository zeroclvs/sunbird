# frozen_string_literal: true

module Sunbird
  class Level
    module Loader
      module_function

      def load(path, entities:)
        absolute_path = File.expand_path(path)

        unless File.extname(absolute_path) == ".rb"
          raise ArgumentError,
            "unsupported level source: #{absolute_path}"
        end

        require absolute_path

        definition_name = constant_name_for(absolute_path)
        definition = Definitions.const_get(
          definition_name,
          false
        )

        terrain = Terrain.new(
          rows: definition.rows,
          tiles: definition.tiles
        )

        validate_spawns!(terrain, definition.spawns, entities)
        validate_controlled_spawn!(
          definition.controlled_spawn,
          definition.spawns
        )
        validate_relations!(
          definition.relations,
          definition.spawns
        )

        Level.new(
          name: definition.name,
          terrain: terrain,
          spawns: definition.spawns,
          relations: definition.relations,
          controlled_spawn: definition.controlled_spawn
        )
      end

      def constant_name_for(path)
        File.basename(path, ".rb")
          .split("_")
          .map!(&:capitalize)
          .join
      end
      private_class_method :constant_name_for

      def validate_spawns!(terrain, spawns, entities)
        keys = {}

        spawns.each do |spawn|
          if keys.key?(spawn.key)
            raise ArgumentError,
              "duplicate spawn key: #{spawn.key.inspect}"
          end

          keys[spawn.key] = true
          entities.fetch(spawn.entity)

          unless terrain.inside?(spawn.x, spawn.y)
            raise ArgumentError,
              "#{spawn.entity} spawn is outside the terrain " \
              "at (#{spawn.x}, #{spawn.y})"
          end

          next if terrain.passable?(spawn.x, spawn.y)

          raise ArgumentError,
            "#{spawn.entity} spawn is on blocked terrain " \
            "at (#{spawn.x}, #{spawn.y})"
        end
      end
      private_class_method :validate_spawns!

      def validate_controlled_spawn!(controlled_spawn, spawns)
        return if spawns.any? { |spawn| spawn.key == controlled_spawn }

        raise ArgumentError,
          "unknown controlled spawn: #{controlled_spawn.inspect}"
      end
      private_class_method :validate_controlled_spawn!

      def validate_relations!(relations, spawns)
        spawn_keys = spawns.map(&:key)

        relations.each do |relation|
          unless spawn_keys.include?(relation.source)
            raise ArgumentError,
              "unknown relation source: #{relation.source.inspect}"
          end

          next if spawn_keys.include?(relation.target)

          raise ArgumentError,
            "unknown relation target: #{relation.target.inspect}"
        end
      end
      private_class_method :validate_relations!
    end
  end
end
