# frozen_string_literal: true

require_relative "test_helper"

class ExplorationModeTest < Minitest::Test
  include SunbirdTestSupport

  def setup
    level = level_with(
      spawns: [
        Sunbird::Level::Spawn.new(
          key: :hero,
          entity: :player,
          x: 2,
          y: 2
        )
      ],
      entry_spawn: :hero
    )

    simulation = Sunbird::Simulation.new(
      level: level,
      entities: actor_catalog
    )
    session = Sunbird::Session.new(
      party: Sunbird::Party.new(
        members: [:hero, :mage],
        leader: :hero
      )
    )
    @mode = Sunbird::Mode::Exploration.new(
      simulation: simulation,
      session: session
    )
  end

  def test_exploration_mode_decides_when_simulation_advances
    result = @mode.advance(input: move_input(:move_east))

    assert_equal :advanced, result
    assert_equal 1, @mode.step_number
  end

  def test_party_leader_is_bound_to_level_entry_spawn
    hero_id = @mode.controlled_instance_id
    position = @mode.world_view.component(hero_id, :position)

    assert_equal hero_id, @mode.instance_id_for_party_member(:hero)
    assert_nil @mode.instance_id_for_party_member(:mage)
    assert_equal [2, 2], [position.x, position.y]
  end

  def test_quit_input_does_not_advance_simulation
    input = Sunbird::Input::Snapshot.from(
      [
        Sunbird::Input::Action.new(
          kind: :quit,
          state: :pressed
        )
      ]
    )
    result = @mode.advance(input: input)

    assert_equal :quit, result
    assert_equal 0, @mode.step_number
  end
end
