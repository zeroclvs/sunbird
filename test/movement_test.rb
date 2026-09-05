# frozen_string_literal: true

require_relative "test_helper"

class MovementTest < Minitest::Test
  def test_blocking_instance_makes_cell_untraversable
    level = Sunbird::Level.new(
      name: :test,
      terrain: Sunbird::Level::Terrain.new(width: 5, height: 5),
      spawns: [],
      relations: [],
      entry_spawn: nil
    )

    world = Sunbird::World.new
    blocker_id = world.spawn(
      position: Sunbird::World::Position.new(x: 2, y: 2),
      collision: Sunbird::World::Collision.new(blocks_movement: true)
    )

    movement = Sunbird::Simulation::Movement.new

    refute movement.traversable?(
      level: level,
      world: world.view,
      x: 2,
      y: 2
    )

    assert movement.traversable?(
      level: level,
      world: world.view,
      x: 2,
      y: 2,
      except_id: blocker_id
    )
  end
end
