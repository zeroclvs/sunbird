# frozen_string_literal: true

require_relative "test_helper"

class PathfindingChaseTest < Minitest::Test
  include SunbirdTestSupport

  def test_chaser_routes_around_blocked_terrain
    tiles = {
      " " => Sunbird::Level::Tile.new(glyph: " ", passable: true),
      "~" => Sunbird::Level::Tile.new(glyph: "~", passable: false)
    }.freeze

    terrain = Sunbird::Level::Terrain.new(
      rows: [
        "       ",
        "       ",
        "       ",
        "   ~   ",
        "       ",
        "       ",
        "       "
      ],
      tiles: tiles
    )

    level = Sunbird::Level.new(
      name: :test,
      terrain: terrain,
      spawns: [
        Sunbird::Level::Spawn.new(
          key: :hero,
          entity: :player,
          x: 5,
          y: 3
        ),
        Sunbird::Level::Spawn.new(
          key: :hunter,
          entity: :goblin,
          x: 1,
          y: 3
        )
      ],
      relations: [
        Sunbird::Level::Relation.new(
          kind: :targets,
          source: :hunter,
          target: :hero
        )
      ],
      controlled_spawn: :hero
    )

    server = Sunbird::Server.new(
      level: level,
      entities: actor_catalog
    )
    goblin_id = instance_id_for(server, :goblin)

    server.tick(input: Sunbird::Input::Snapshot.empty)

    position = server.world_view.component(goblin_id, :position)

    assert_equal [2, 3], [position.x, position.y]
  end
end
