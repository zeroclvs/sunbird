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
      controlled_spawn: :hero
    )

    simulation = Sunbird::Simulation.new(
      level: level,
      entities: actor_catalog
    )

    @mode = Sunbird::Mode::Exploration.new(
      simulation: simulation
    )
  end

  def test_exploration_mode_decides_when_simulation_advances
    result = @mode.advance(input: move_input(:move_east))

    assert_equal :advanced, result
    assert_equal 1, @mode.step_number
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
