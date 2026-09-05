# frozen_string_literal: true

require_relative "test_helper"

class ActorStateTest < Minitest::Test
  def test_actor_state_owns_persistent_vitals_and_stats
    actor = Sunbird::ActorState.new(
      vitals: Sunbird::ActorState::Vitals.new(
        hp: 10,
        max_hp: 10,
        mp: 4,
        max_mp: 4
      ),
      stats: Sunbird::ActorState::Stats.new(
        attack: 2
      )
    )

    assert_equal 10, actor.vitals.hp
    assert_equal 4, actor.vitals.mp
    assert_equal 2, actor.stats.attack
  end

  def test_with_replaces_one_value_without_mutating_original
    actor = Sunbird::ActorState.new(
      vitals: Sunbird::ActorState::Vitals.new(
        hp: 10,
        max_hp: 10,
        mp: 4,
        max_mp: 4
      ),
      stats: Sunbird::ActorState::Stats.new(
        attack: 2
      )
    )

    replacement = actor.with(
      vitals: Sunbird::ActorState::Vitals.new(
        hp: 7,
        max_hp: 10,
        mp: 4,
        max_mp: 4
      )
    )

    assert_equal 10, actor.vitals.hp
    assert_equal 7, replacement.vitals.hp
    assert_equal 2, replacement.stats.attack
  end
end
