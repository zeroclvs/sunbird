# frozen_string_literal: true

require "minitest/autorun"

$LOAD_PATH.unshift(
  File.expand_path("../lib", __dir__)
)

require "sunbird"

module SunbirdTestPaths
  ENTITY_PATH = File.expand_path(
    "../content/entities/actors.rb",
    __dir__
  )

  LEVEL_PATH = File.expand_path(
    "../content/levels/test_field.rb",
    __dir__
  )
end

module SunbirdTestSupport
  def actor_catalog(goblin_behavior: :chase)
    player = Sunbird::Entity.new(
      name: :player,
      components: {
        health: Sunbird::World::Health.new(current: 10, max: 10),
        collision: Sunbird::World::Collision.new(blocks_movement: true)
      }.freeze
    )

    goblin = Sunbird::Entity.new(
      name: :goblin,
      components: {
        health: Sunbird::World::Health.new(current: 4, max: 4),
        behavior: Sunbird::World::Behavior.new(kind: goblin_behavior),
        collision: Sunbird::World::Collision.new(blocks_movement: true)
      }.freeze
    )

    Sunbird::Entity::Catalog.new([player, goblin])
  end

  def level_with(
    width: 7,
    height: 7,
    spawns:,
    relations: [],
    controlled_spawn:
  )
    Sunbird::Level.new(
      name: :test,
      terrain: Sunbird::Level::Terrain.new(
        width: width,
        height: height
      ),
      spawns: spawns,
      relations: relations,
      controlled_spawn: controlled_spawn
    )
  end

  def move_input(kind)
    Sunbird::Input::Snapshot.from(
      [
        Sunbird::Input::Action.new(
          kind: kind,
          state: :pressed
        )
      ]
    )
  end

  def advance_simulation(simulation, input)
    commands = simulation.plan(input: input)
    simulation.step(commands: commands)
  end

  def instance_id_for(simulation, entity_name)
    simulation.world_view.instance_ids.find do |instance_id|
      ref = simulation.world_view.component(instance_id, :entity_ref)
      ref&.name == entity_name
    end
  end
end
