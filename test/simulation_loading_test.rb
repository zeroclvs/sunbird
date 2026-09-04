# frozen_string_literal: true

require_relative "test_helper"

class SimulationLoadingTest < Minitest::Test
  include SunbirdTestSupport

  def setup
    @level = level_with(
      spawns: [
        Sunbird::Level::Spawn.new(
          key: :hero,
          entity: :player,
          x: 1,
          y: 1
        ),
        Sunbird::Level::Spawn.new(
          key: :hunter,
          entity: :goblin,
          x: 4,
          y: 1
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

    @simulation = Sunbird::Simulation.new(
      level: @level,
      entities: actor_catalog
    )
  end

  def test_controlled_instance_comes_from_level_spawn_key
    ref = @simulation.world_view.component(
      @simulation.controlled_id,
      :entity_ref
    )

    assert_equal :player, ref.name
  end

  def test_static_level_relation_becomes_runtime_relation
    goblin_id = instance_id_for(@simulation, :goblin)

    assert_equal(
      [@simulation.controlled_id],
      @simulation.world_view.relation_targets(
        kind: :targets,
        source_id: goblin_id
      )
    )
  end
end
