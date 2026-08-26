# frozen_string_literal: true

require_relative "test_helper"

class LevelLoadingTest < Minitest::Test
  include SunbirdTestPaths

  def setup
    @entities = Sunbird::Entity::Loader.load(
      ENTITY_PATH
    )

    @loaded = Sunbird::Level::Loader.load(
      LEVEL_PATH,
      entities: @entities
    )
  end

  def test_source_level_loads_map_and_spawns
    assert_equal 44, @loaded.map.width
    assert_equal 14, @loaded.map.height
    assert_equal 4, @loaded.spawns.length

    player = @loaded.spawns.find do |spawn|
      spawn.entity == :player
    end

    refute_nil player
    assert_equal [3, 3], [player.x, player.y]
  end

  def test_landscape_controls_static_passability
    map = @loaded.map

    assert map.passable?(3, 3)
    assert map.passable?(7, 1)
    refute map.passable?(27, 1)
    refute map.passable?(0, 5)
    refute map.passable?(12, 0)
  end
end
