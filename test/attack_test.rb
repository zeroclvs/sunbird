# frozen_string_literal: true

require_relative "test_helper"

class AttackTest < Minitest::Test
  def test_adjacent_chasing_goblin_damages_target
    level = Sunbird::Level::Map.new(
      width: 5,
      height: 5
    )

    player = Sunbird::Entity.new(
      name: :player,
      components: {
        health: Sunbird::World::Health.new(
          current: 10,
          max: 10
        ),
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
        x: 3,
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

    server.tick(
      input: Sunbird::Input::Snapshot.empty
    )

    health = server.world_view.component(
      server.player_instance,
      :health
    )

    assert_equal 9, health.current
    assert_equal 10, health.max
  end
end
