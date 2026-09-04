# frozen_string_literal: true

require_relative "test_helper"

class SimulationStepTest < Minitest::Test
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

    @simulation = Sunbird::Simulation.new(
      level: level,
      entities: actor_catalog
    )
  end

  def test_step_applies_explicit_commands
    commands = Sunbird::Simulation::Commands::Buffer.new(
      [
        Sunbird::Simulation::Commands::Move.new(
          instance_id: @simulation.controlled_id,
          dx: 1,
          dy: 0
        )
      ]
    )

    result = @simulation.step(commands: commands)
    position = @simulation.world_view.component(
      @simulation.controlled_id,
      :position
    )

    assert_equal [3, 2], [position.x, position.y]
    assert_equal 1, result
    assert_equal 1, @simulation.step_number
  end

  def test_plan_does_not_advance_world
    commands = @simulation.plan(input: move_input(:move_east))
    position = @simulation.world_view.component(
      @simulation.controlled_id,
      :position
    )

    assert_equal 1, commands.size
    assert_equal [2, 2], [position.x, position.y]
    assert_equal 0, @simulation.step_number
  end

  def test_world_view_has_no_mutation_api
    refute_respond_to @simulation.world_view, :set_component
  end
end
