# frozen_string_literal: true

require_relative "test_helper"

class CollisionTest < Minitest::Test
  def test_blocking_instance_prevents_movement
    level = Sunbird::Level::Map.new(
      width: 5,
      height: 5
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
        x: 2,
        y: 2
      ),
      Sunbird::Level::Spawn.new(
        entity: :goblin,
        x: 3,
        y: 2
      )
    ]

    server = Sunbird::Server.new(
      level: level,
      spawns: spawns,
      entities: entities
    )

    input = Sunbird::Input::Snapshot.from(
      [
        Sunbird::Input::Action.new(
          kind: :move_east,
          state: :pressed
        )
      ]
    )

    server.tick(input: input)

    position = server.world_view.component(
      server.player_instance,
      :position
    )

    assert_equal [2, 2], [position.x, position.y]
  end
end
