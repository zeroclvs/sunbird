# frozen_string_literal: true

require_relative "test_helper"

class ServerTickTest < Minitest::Test
  include SunbirdTestSupport

  def setup
    level = level_with(
      spawns: [
        Sunbird::Level::Spawn.new(
          key: :hero,
          entity: :player,
          x: 2,
          y: 2
        )
      ],
      controlled_spawn: :hero
    )

    @server = Sunbird::Server.new(
      level: level,
      entities: actor_catalog
    )
  end

  def test_tick_is_authoritative_movement_entry_point
    result = @server.tick(input: move_input(:move_east))
    position = @server.world_view.component(
      @server.controlled_id,
      :position
    )

    assert_equal [3, 2], [position.x, position.y]
    assert_equal 1, result
    assert_equal 1, @server.tick_number
  end

  def test_world_view_has_no_mutation_api
    refute_respond_to @server.world_view, :set_component
  end
end
