# frozen_string_literal: true

require_relative "test_helper"

class RuntimeRelationsTest < Minitest::Test
  def test_world_stores_runtime_relation_between_instances
    world = Sunbird::World.new
    goblin_id = world.spawn
    player_id = world.spawn

    world.add_relation(
      kind: :targets,
      source_id: goblin_id,
      target_id: player_id
    )

    assert_equal(
      [player_id],
      world.view.relation_targets(
        kind: :targets,
        source_id: goblin_id
      )
    )
  end

  def test_view_cannot_add_runtime_relations
    refute_respond_to(
      Sunbird::World.new.view,
      :add_relation
    )
  end
end
