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
      @area_state = AreaState.new
      @step_number = 0

      movement = Movement.new
      @planner = Planner.new(
        relevance: relevance,
        pathfinder: Pathfinder.new(movement: movement)
      )
      @resolver = Resolver.new(movement: movement)

      @spawn_ids = instantiate_spawns(
        level.spawns,
        entities
      ).freeze
      instantiate_relations(level.relations, @spawn_ids)
    end

    def plan(input:, controlled_id:)
      @planner.build(
        input: input,
        level: @level,
        world: @area_state.view,
        controlled_id: controlled_id
      )
    end

    def step(commands:)
      effects = @resolver.resolve(
        area: @area_state,
        level: @level,
        commands: commands
      )

      @step_number += 1

      yield effects if block_given?

      @step_number
    end

    def bind_actor(actor_key:, instance_id:)
      unless @area_state.instance?(instance_id)
        raise ArgumentError,
          "unknown instance_id for actor binding: #{instance_id.inspect}"
      end

      @area_state.set_component(
        instance_id,
        :actor_ref,
        AreaState::ActorRef.new(
          actor_key: actor_key.to_sym
        )
      )
    end

    def area_view
      @area_state.view
    end

    # Transitional v0.4 compatibility alias.
    alias world_view area_view

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
        @area_state.add_relation(
          kind: relation.kind,
          source_id: spawn_ids.fetch(relation.source),
          target_id: spawn_ids.fetch(relation.target)
        )
      end
    end

    def instantiate(entity, spawn)
      components = entity.components.merge(
        entity_ref: AreaState::EntityRef.new(
          name: entity.name
        ),
        position: AreaState::Position.new(
          x: spawn.x,
          y: spawn.y
        )
      )

      @area_state.spawn(**components)
    end
  end
end
