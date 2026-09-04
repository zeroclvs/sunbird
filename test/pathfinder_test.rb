# frozen_string_literal: true

require_relative "test_helper"

class PathfinderTest < Minitest::Test
  def test_finds_step_around_blocked_terrain
    tiles = {
      " " => Sunbird::Level::Tile.new(render_key: :ground, glyph: " ", passable: true),
      "~" => Sunbird::Level::Tile.new(render_key: :water, glyph: "~", passable: false)
    }.freeze

    terrain = Sunbird::Level::Terrain.new(
      rows: [
        "     ",
        "     ",
        "  ~  ",
        "     ",
        "     "
      ],
      tiles: tiles
    )

    level = Sunbird::Level.new(
      name: :test,
      terrain: terrain,
      spawns: [],
      relations: [],
      controlled_spawn: nil
    )

    world = Sunbird::World.new
    source_id = world.spawn(
      position: Sunbird::World::Position.new(x: 1, y: 2),
      collision: Sunbird::World::Collision.new(blocks_movement: true)
    )
    target_id = world.spawn(
      position: Sunbird::World::Position.new(x: 3, y: 2),
      collision: Sunbird::World::Collision.new(blocks_movement: true)
    )

    step = Sunbird::Simulation::Pathfinder.new.next_step(
      level: level,
      world: world.view,
      source_id: source_id,
      target_id: target_id
    )

    assert_equal [0, -1], step
  end

  def test_returns_nil_when_source_is_already_adjacent
    level = Sunbird::Level.new(
      name: :test,
      terrain: Sunbird::Level::Terrain.new(width: 5, height: 5),
      spawns: [],
      relations: [],
      controlled_spawn: nil
    )

    world = Sunbird::World.new
    source_id = world.spawn(
      position: Sunbird::World::Position.new(x: 1, y: 1),
      collision: Sunbird::World::Collision.new(blocks_movement: true)
    )
    target_id = world.spawn(
      position: Sunbird::World::Position.new(x: 2, y: 1),
      collision: Sunbird::World::Collision.new(blocks_movement: true)
    )

    step = Sunbird::Simulation::Pathfinder.new.next_step(
      level: level,
      world: world.view,
      source_id: source_id,
      target_id: target_id
    )

    assert_nil step
  end
end
