# frozen_string_literal: true

require_relative "test_helper"

class PathfindingChaseTest < Minitest::Test
  def test_goblin_routes_around_water_to_reach_player
    tiles = {
      " " => Sunbird::Level::Tile.new(
        glyph: " ",
        passable: true
      ),
      "~" => Sunbird::Level::Tile.new(
        glyph: "~",
        passable: false
      )
    }.freeze

    level = Sunbird::Level::Map.new(
      rows: [
        "       ",
        "   ~   ",
        "   ~   ",
        "   ~   ",
        "       "
      ],
      tiles: tiles
    )

    player = Sunbird::Entity.new(
      name: :player,
      components: {
        collision: Sunbird::World::Collision.new(
          blocks_movement: true
        )
      }.freeze
    )

    goblin = Sunbird::Entity.new(
      name: :goblin,
      components: {
        behavior: Sunbird::World::Behavior.new(
          kind: :chase
        ),
        collision: Sunbird::World::Collision.new(
          blocks_movement: true
        )
      }.freeze
    )

    entities = Sunbird::Entity::Registry.new(
      [player, goblin]
    )

    spawns = [
      Sunbird::Level::Spawn.new(
        entity: :player,
        x: 5,
        y: 2
      ),
      Sunbird::Level::Spawn.new(
        entity: :goblin,
        x: 2,
        y: 2
      )
    ]

    server = Sunbird::Server.new(
      level: level,
      spawns: spawns,
      entities: entities
    )

    goblin_id = server.world_view.instance_ids.find do |instance_id|
      identity = server.world_view.component(
        instance_id,
        :identity
      )

      identity.entity == :goblin
    end

    8.times do
      server.tick(
        input: Sunbird::Input::Snapshot.empty
      )
    end

    goblin_position = server.world_view.component(
      goblin_id,
      :position
    )
    player_position = server.world_view.component(
      server.player_instance,
      :position
    )

    distance =
      (goblin_position.x - player_position.x).abs +
      (goblin_position.y - player_position.y).abs

    assert_equal 1, distance
  end
end
