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

  DIALOGUE_PATH = File.expand_path(
    "../content/dialogue/test_field.rb",
    __dir__
  )
end

module SunbirdTestSupport
  def actor_catalog(goblin_behavior: :chase)
    player = Sunbird::Entity.new(
      name: :player,
      components: {
        collision: Sunbird::World::Collision.new(blocks_movement: true),
        facing: Sunbird::World::Facing.new(direction: :south),
        combatant: Sunbird::World::Combatant.new(attack: 2)
      }.freeze
    )
    goblin = Sunbird::Entity.new(
      name: :goblin,
      components: {
        health: Sunbird::World::Health.new(current: 4, max: 4),
        behavior: Sunbird::World::Behavior.new(kind: goblin_behavior),
        collision: Sunbird::World::Collision.new(blocks_movement: true),
        combatant: Sunbird::World::Combatant.new(attack: 1)
      }.freeze
    )
    villager = Sunbird::Entity.new(
      name: :villager,
      components: {
        collision: Sunbird::World::Collision.new(blocks_movement: true),
        interactable: Sunbird::World::Interactable.new(
          dialogue_key: :village_greeting
        )
      }.freeze
    )

    Sunbird::Entity::Catalog.new([player, goblin, villager])
  end

  def dialogue_catalog
    Sunbird::Dialogue::Catalog.new(
      {
        village_greeting: [
          "First line.",
          "Second line."
        ]
      }
    )
  end

  def test_session
    Sunbird::Session.new(
      party: Sunbird::Party.new(
        members: [:hero, :mage],
        leader: :hero
      ),
      vitals: {
        hero: Sunbird::Session::Vitals.new(
          hp: 10,
          max_hp: 10,
          mp: 4,
          max_mp: 4
        ),
        mage: Sunbird::Session::Vitals.new(
          hp: 8,
          max_hp: 8,
          mp: 8,
          max_mp: 8
        )
      }
    )
  end

  def level_with(
    width: 7,
    height: 7,
    spawns:,
    relations: [],
    entry_spawn:
  )
    Sunbird::Level.new(
      name: :test,
      terrain: Sunbird::Level::Terrain.new(
        width: width,
        height: height
      ),
      spawns: spawns,
      relations: relations,
      entry_spawn: entry_spawn
    )
  end

  def action_input(kind)
    Sunbird::Input::Snapshot.from(
      [
        Sunbird::Input::Action.new(
          kind: kind,
          state: :pressed
        )
      ]
    )
  end

  def move_input(kind)
    action_input(kind)
  end

  def advance_simulation(
    simulation,
    input,
    controlled_id: default_controlled_id(simulation)
  )
    commands = simulation.plan(
      input: input,
      controlled_id: controlled_id
    )
    simulation.step(commands: commands)
  end

  def default_controlled_id(simulation)
    entry_spawn = simulation.level.entry_spawn
    return unless entry_spawn

    simulation.instance_id_for_spawn(entry_spawn)
  end

  def instance_id_for(simulation, entity_name)
    simulation.world_view.instance_ids.find do |instance_id|
      ref = simulation.world_view.component(instance_id, :entity_ref)
      ref&.name == entity_name
    end
  end
end
