# frozen_string_literal: true

require_relative "test_helper"

class ActorBindingsTest < Minitest::Test
  def test_bindings_map_stable_actor_keys_to_local_instance_ids
    bindings = Sunbird::ActorBindings.new(
      hero: 7,
      mage: 11
    )

    assert_equal 7, bindings.fetch(:hero)
    assert_equal 11, bindings[:mage]
    assert_equal :hero, bindings.binding(:hero).actor_key
  end

  def test_bindings_reject_invalid_runtime_identity
    error = assert_raises(ArgumentError) do
      Sunbird::ActorBindings.new(hero: -1)
    end

    assert_match "instance_id", error.message
  end
end
