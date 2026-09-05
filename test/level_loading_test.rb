# frozen_string_literal: true

require_relative "test_helper"

class LevelLoadingTest < Minitest::Test
  include SunbirdTestPaths

  def setup
    entities = Sunbird::Entity::Loader.load(ENTITY_PATH)
    @level = Sunbird::Level::Loader.load(
      LEVEL_PATH,
      entities: entities
    )
  end

  def test_loader_returns_complete_level
    assert_instance_of Sunbird::Level, @level
    assert_instance_of Sunbird::Level::Terrain, @level.terrain
    assert_equal :test_field, @level.name
    assert_equal 44, @level.width
    assert_equal 14, @level.height
    assert_equal 4, @level.spawns.length
  end

  def test_level_owns_entry_spawn_and_static_relations
    assert_equal :player, @level.entry_spawn
    assert_equal 3, @level.relations.length
    assert @level.relations.all? { |relation| relation.kind == :targets }
  end

  def test_terrain_controls_static_passability
    assert_equal :ground, @level.render_key_at(3, 3)
    assert_equal :grass, @level.render_key_at(7, 1)
    assert @level.passable?(3, 3)
    assert @level.passable?(7, 1)
    refute @level.passable?(27, 1)
    refute @level.passable?(0, 5)
    refute @level.passable?(12, 0)
  end
end
