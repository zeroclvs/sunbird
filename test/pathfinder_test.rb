# frozen_string_literal: true

require_relative "test_helper"

class PathfinderTest < Minitest::Test
  TILES = {
    " " => Sunbird::Level::Tile.new(
      glyph: " ",
      passable: true
    ),
    "~" => Sunbird::Level::Tile.new(
      glyph: "~",
      passable: false
    )
  }.freeze

  def test_routes_around_impassable_terrain
    level = Sunbird::Level::Map.new(
      rows: [
        "       ",
        "   ~   ",
        "   ~   ",
        "   ~   ",
        "       "
      ],
      tiles: TILES
    )

    world, source_id, target_id = build_world(
      source: [2, 2],
      target: [5, 2]
    )

    step = Sunbird::Server::Pathfinder.new.next_step(
      level: level,
      world: world.view,
      source_id: source_id,
      target_id: target_id
    )

    assert_includes [[0, -1], [0, 1]], step
  end

  def test_routes_around_blocking_instance
    level = Sunbird::Level::Map.new(
      width: 7,
      height: 5
    )

    world, source_id, target_id = build_world(
      source: [2, 2],
      target: [5, 2]
    )

    world.spawn(
      position: Sunbird::World::Position.new(x: 3, y: 2),
      collision: Sunbird::World::Collision.new(
        blocks_movement: true
      )
    )

    step = Sunbird::Server::Pathfinder.new.next_step(
      level: level,
      world: world.view,
      source_id: source_id,
      target_id: target_id
    )

    assert_includes [[0, -1], [0, 1]], step
  end

  private

  def build_world(source:, target:)
    world = Sunbird::World.new

    source_id = world.spawn(
      position: Sunbird::World::Position.new(
        x: source[0],
        y: source[1]
      ),
      collision: Sunbird::World::Collision.new(
        blocks_movement: true
      )
    )

    target_id = world.spawn(
      position: Sunbird::World::Position.new(
        x: target[0],
        y: target[1]
      ),
      collision: Sunbird::World::Collision.new(
        blocks_movement: true
      )
    )

    [world, source_id, target_id]
  end
end
