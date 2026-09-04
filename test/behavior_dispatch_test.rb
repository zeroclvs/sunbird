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
      controlled_spawn: :hero
    )

    server = Sunbird::Server.new(
      level: level,
      entities: actor_catalog(goblin_behavior: :unknown)
    )

    error = assert_raises(ArgumentError) do
      server.tick(input: Sunbird::Input::Snapshot.empty)
    end

    assert_equal "unknown behavior: :unknown", error.message
  end
end
