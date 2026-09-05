# frozen_string_literal: true

module Sunbird
  class Level
    module Loader
      module_function

      def load(path, entities:)
        absolute_path = Content::RubySource.absolute_path(
          path,
          kind: :level
        )

        require absolute_path

        definition_name = Content::RubySource.constant_name_for(
          absolute_path
        )
        definition = Definitions.const_get(
          definition_name,
          false
        )

        terrain = Terrain.new(
          rows: definition.rows,
          tiles: definition.tiles
        )

        validate_spawns!(terrain, definition.spawns, entities)
        validate_entry_spawn!(
          definition.entry_spawn,
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
          entry_spawn: definition.entry_spawn
        )
      end

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

      def validate_entry_spawn!(entry_spawn, spawns)
        return if entry_spawn.nil?
        return if spawns.any? { |spawn| spawn.key == entry_spawn }

        raise ArgumentError,
          "unknown entry spawn: #{entry_spawn.inspect}"
      end
      private_class_method :validate_entry_spawn!

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
