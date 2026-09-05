# frozen_string_literal: true

require_relative "test_helper"

class ExplorationBattleTest < Minitest::Test
  include SunbirdTestSupport

  def test_interacting_with_adjacent_combatant_pushes_battle
    level = level_with(
      spawns: [
        Sunbird::Level::Spawn.new(
          key: :hero,
          entity: :player,
          x: 2,
          y: 2
        ),
        Sunbird::Level::Spawn.new(
          key: :goblin,
          entity: :goblin,
          x: 3,
          y: 2
        )
      ],
      entry_spawn: :hero
    )
    simulation = Sunbird::Simulation.new(
      level: level,
      entities: actor_catalog
    )
    mode = Sunbird::Mode::Exploration.new(
      simulation: simulation,
      session: test_session,
      dialogues: dialogue_catalog
    )

    mode.advance(input: move_input(:move_east))
    before = mode.step_number

    result = mode.advance(input: action_input(:interact))

    assert_instance_of Sunbird::Mode::Push, result
    assert_instance_of Sunbird::Mode::Battle, result.mode
    assert_equal before, mode.step_number
  end
end
