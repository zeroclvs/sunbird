# frozen_string_literal: true

module Sunbird
  class Simulation
    attr_reader :level, :step_number

    def initialize(
      level:,
      entities:,
      relevance: Relevance.new
    )
      @level = level
      @world = World.new
      @step_number = 0

      movement = Movement.new
      @planner = Planner.new(
        relevance: relevance,
        pathfinder: Pathfinder.new(movement: movement)
      )
      @resolver = Resolver.new(movement: movement)
      @spawn_ids = instantiate_spawns(level.spawns, entities).freeze
      instantiate_relations(level.relations, @spawn_ids)
    end

    def plan(input:, controlled_id:)
      @planner.build(
        input: input,
        level: @level,
        world: @world.view,
        controlled_id: controlled_id
      )
    end

    def step(commands:)
      @resolver.resolve(
        world: @world,
        level: @level,
        commands: commands
      )
      @step_number += 1
    end

    def world_view
      @world.view
    end

    def instance_id_for_spawn(spawn_key)
      @spawn_ids.fetch(spawn_key)
    end

    private

    def instantiate_spawns(spawns, entities)
      spawns.to_h do |spawn|
        entity = entities.fetch(spawn.entity)
        [spawn.key, instantiate(entity, spawn)]
      end
    end

    def instantiate_relations(relations, spawn_ids)
      relations.each do |relation|
        @world.add_relation(
          kind: relation.kind,
          source_id: spawn_ids.fetch(relation.source),
          target_id: spawn_ids.fetch(relation.target)
        )
      end
    end

    def instantiate(entity, spawn)
      components = entity.components.merge(
        entity_ref: World::EntityRef.new(
          name: entity.name
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
