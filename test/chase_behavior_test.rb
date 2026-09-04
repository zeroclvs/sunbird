# frozen_string_literal: true

require_relative "test_helper"

class ChaseBehaviorTest < Minitest::Test
  include SunbirdTestSupport

  def test_adjacent_chaser_attacks_target
    server = build_server(
      hero_position: [3, 3],
      goblin_position: [2, 3]
    )

    server.tick(input: Sunbird::Input::Snapshot.empty)

    health = server.world_view.component(server.controlled_id, :health)
    assert_equal 9, health.current
  end

  def test_chaser_moves_toward_non_adjacent_target
    server = build_server(
      hero_position: [5, 3],
      goblin_position: [2, 3]
    )
    goblin_id = instance_id_for(server, :goblin)

    server.tick(input: Sunbird::Input::Snapshot.empty)

    position = server.world_view.component(goblin_id, :position)
    assert_equal [3, 3], [position.x, position.y]
  end

  private

  def build_server(hero_position:, goblin_position:)
    level = level_with(
      spawns: [
        Sunbird::Level::Spawn.new(
          key: :hero,
          entity: :player,
          x: hero_position[0],
          y: hero_position[1]
        ),
        Sunbird::Level::Spawn.new(
          key: :hunter,
          entity: :goblin,
          x: goblin_position[0],
          y: goblin_position[1]
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

    Sunbird::Server.new(
      level: level,
      entities: actor_catalog
    )
  end
end
