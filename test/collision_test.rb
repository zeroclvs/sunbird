# frozen_string_literal: true

require_relative "test_helper"

class CollisionTest < Minitest::Test
  include SunbirdTestSupport

  def test_blocking_instance_prevents_controlled_movement
    level = level_with(
      spawns: [
        Sunbird::Level::Spawn.new(
          key: :hero,
          entity: :player,
          x: 2,
          y: 2
        ),
        Sunbird::Level::Spawn.new(
          key: :blocker,
          entity: :goblin,
          x: 3,
          y: 2
        )
      ],
      entry_spawn: :hero
    )

    simulation = Sunbird::Simulation.new(
      level: level,
      entities: actor_catalog(goblin_behavior: :idle)
    )

    advance_simulation(simulation, move_input(:move_east))

    position = simulation.world_view.component(
      simulation.instance_id_for_spawn(:hero),
      :position
    )

    assert_equal [2, 2], [position.x, position.y]
  end
end
