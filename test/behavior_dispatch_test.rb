# frozen_string_literal: true

require_relative "test_helper"

class BehaviorDispatchTest < Minitest::Test
  include SunbirdTestSupport

  def test_unknown_behavior_kind_raises_argument_error
    level = level_with(
      spawns: [
        Sunbird::Level::Spawn.new(
          key: :hero,
          entity: :player,
          x: 2,
          y: 2
        ),
        Sunbird::Level::Spawn.new(
          key: :stranger,
          entity: :goblin,
          x: 4,
          y: 2
        )
      ],
      entry_spawn: :hero
    )

    simulation = Sunbird::Simulation.new(
      level: level,
      entities: actor_catalog(goblin_behavior: :unknown)
    )

    error = assert_raises(ArgumentError) do
      simulation.plan(
        input: Sunbird::Input::Snapshot.empty,
        controlled_id: simulation.instance_id_for_spawn(:hero)
      )
    end

    assert_equal "unknown behavior: :unknown", error.message
  end
end
