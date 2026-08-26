# frozen_string_literal: true

require_relative "test_helper"

class EntityLoadingTest < Minitest::Test
  include SunbirdTestPaths

  def test_entities_define_reusable_component_recipes
    entities = Sunbird::Entity::Loader.load(
      ENTITY_PATH
    )

    goblin = entities.fetch(:goblin)

    assert_equal :goblin, goblin.name
    assert_equal(
      "G",
      goblin.components.fetch(:renderable).glyph
    )
    assert(
      goblin.components
        .fetch(:collision)
        .blocks_movement
    )
  end
end
