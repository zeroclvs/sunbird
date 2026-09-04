# frozen_string_literal: true

require_relative "test_helper"

class EntityLoadingTest < Minitest::Test
  include SunbirdTestPaths

  def test_loader_returns_catalog_of_reusable_entities
    entities = Sunbird::Entity::Loader.load(ENTITY_PATH)
    goblin = entities.fetch(:goblin)

    assert_instance_of Sunbird::Entity::Catalog, entities
    assert_equal :goblin, goblin.name
    assert_equal :chase, goblin.components.fetch(:behavior).kind
    assert_equal "G", goblin.components.fetch(:renderable).glyph
  end
end
