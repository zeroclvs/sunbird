# frozen_string_literal: true

require_relative "test_helper"

class GoblinBehaviorTest < Minitest::Test
  def test_wandering_goblin_produces_movement
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
          kind: :wander
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
        x: 1,
        y: 1
      ),
      Sunbird::Level::Spawn.new(
        entity: :goblin,
        x: 3,
        y: 3
      )
    ]

    server = Sunbird::Server.new(
      level: level,
      spawns: spawns,
      entities: entities
    )

    goblin_instance =
      server.world_view.instance_ids.find do |instance_id|
        identity = server.world_view.component(
          instance_id,
          :identity
        )

        identity.entity == :goblin
      end

    before = server.world_view.component(
      goblin_instance,
      :position
    )

    server.tick(
      input: Sunbird::Input::Snapshot.empty
    )

    after = server.world_view.component(
      goblin_instance,
      :position
    )

    distance =
      (after.x - before.x).abs +
      (after.y - before.y).abs

    assert_equal 1, distance
  end
end