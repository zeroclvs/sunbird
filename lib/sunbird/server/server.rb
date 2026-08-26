# frozen_string_literal: true

module Sunbird
  class Server
    attr_reader :level, :tick_number, :player_instance

    def initialize(
      level:,
      spawns:,
      entities:,
      activation: Activation.new
    )
      @level = level
      @world = World.new
      @tick_number = 0

      @tick_builder = TickBuilder.new(
        activation: activation
      )
      @resolver = Resolver.new

      @player_instance = load_spawns(
        spawns,
        entities
      )

      establish_initial_relations
    end

    def tick(input:)
      commands = @tick_builder.build(
        input: input,
        level: @level,
        world: @world.view,
        player_instance: @player_instance
      )

      @resolver.resolve(
        world: @world,
        level: @level,
        commands: commands
      )

      @tick_number += 1
    end

    def world_view
      @world.view
    end

    private

    def load_spawns(spawns, entities)
      player_instance = nil

      spawns.each do |spawn|
        entity = entities.fetch(spawn.entity)

        instance_id = instantiate(
          entity,
          spawn
        )

        next unless entity.name == :player

        if player_instance
          raise "level contains more than one player spawn"
        end

        player_instance = instance_id
      end

      player_instance ||
        raise("level does not contain a player spawn")
    end

    def establish_initial_relations
      @world.instance_ids.each do |instance_id|
        next if instance_id == @player_instance

        identity = @world.component(
          instance_id,
          :identity
        )

        next unless identity.entity == :goblin

        @world.add_relation(
          kind: :targets,
          source_id: instance_id,
          target_id: @player_instance
        )
      end
    end

    def instantiate(entity, spawn)
      components = entity.components.merge(
        identity: World::Identity.new(
          entity: entity.name
        ),
        position: World::Position.new(
          x: spawn.x,
          y: spawn.y
        )
      )

      @world.spawn(**components)
    end
  end
end
