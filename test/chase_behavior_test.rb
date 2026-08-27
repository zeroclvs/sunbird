# frozen_string_literal: true

require_relative "test_helper"

class ChaseBehaviorTest < Minitest::Test
  def test_chasing_goblin_moves_toward_target
    server, goblin_id = build_server(
      player_position: [5, 5],
      goblin_position: [3, 3]
    )

    server.tick(
      input: Sunbird::Input::Snapshot.empty
    )

    position = server.world_view.component(
      goblin_id,
      :position
    )

    assert_equal [4, 3], [position.x, position.y]
  end

  def test_chasing_goblin_cannot_enter_target_tile
    server, goblin_id = build_server(
      player_position: [4, 3],
      goblin_position: [3, 3]
    )

    server.tick(
      input: Sunbird::Input::Snapshot.empty
    )

    position = server.world_view.component(
      goblin_id,
      :position
    )

    assert_equal [3, 3], [position.x, position.y]
  end

  private

  def build_server(player_position:, goblin_position:)
    level = Sunbird::Level::Map.new(
      width: 7,
      height: 7
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
        x: player_position[0],
        y: player_position[1]
      ),
      Sunbird::Level::Spawn.new(
        entity: :goblin,
        x: goblin_position[0],
        y: goblin_position[1]
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

    [server, goblin_id]
  end
end
