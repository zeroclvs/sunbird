# frozen_string_literal: true

require_relative "test_helper"

class ServerTickTest < Minitest::Test
  include SunbirdTestPaths

  def setup
    entities = Sunbird::Entity::Loader.load(
      ENTITY_PATH
    )

    loaded = Sunbird::Level::Loader.load(
      LEVEL_PATH,
      entities: entities
    )

    @server = Sunbird::Server.new(
      level: loaded.map,
      spawns: loaded.spawns,
      entities: entities
    )
  end

  def test_tick_is_authoritative_movement_entry_point
    player = @server.player_instance

    before = @server.world_view.component(
      player,
      :position
    )

    input = Sunbird::Input::Snapshot.from(
      [
        Sunbird::Input::Action.new(
          kind: :move_east,
          state: :pressed
        )
      ]
    )

    result = @server.tick(input: input)

    after = @server.world_view.component(
      player,
      :position
    )

    assert_equal [3, 3], [before.x, before.y]
    assert_equal [4, 3], [after.x, after.y]
    assert_equal 1, result
    assert_equal 1, @server.tick_number
  end

  def test_world_view_has_no_mutation_api
    refute_respond_to(
      @server.world_view,
      :set_component
    )
  end
end
