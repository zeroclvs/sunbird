# frozen_string_literal: true

require_relative "test_helper"

class ServerRelationsTest < Minitest::Test
  include SunbirdTestPaths

  def test_loaded_goblins_target_player
    entities = Sunbird::Entity::Loader.load(
      ENTITY_PATH
    )

    loaded = Sunbird::Level::Loader.load(
      LEVEL_PATH,
      entities: entities
    )

    server = Sunbird::Server.new(
      level: loaded.map,
      spawns: loaded.spawns,
      entities: entities
    )

    goblin_ids = server.world_view.instance_ids.select do |instance_id|
      identity = server.world_view.component(
        instance_id,
        :identity
      )

      identity.entity == :goblin
    end

    goblin_ids.each do |goblin_id|
      assert_equal(
        [server.player_instance],
        server.world_view.relation_targets(
          kind: :targets,
          source_id: goblin_id
        )
      )
    end
  end
end
