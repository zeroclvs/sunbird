# frozen_string_literal: true

require_relative "test_helper"

class SessionTest < Minitest::Test
  include SunbirdTestSupport

  def test_session_owns_persistent_actor_state
    session = test_session

    assert_equal [:hero, :mage], session.party.members
    assert_equal [:hero, :mage], session.actor_keys

    hero = session.actor(:hero)
    assert_equal 10, hero.vitals.hp
    assert_equal 4, hero.vitals.mp
    assert_equal 2, hero.stats.attack
  end

  def test_session_can_exist_without_party_policy
    actor = Sunbird::ActorState.new(
      vitals: Sunbird::ActorState::Vitals.new(
        hp: 10,
        max_hp: 10,
        mp: 0,
        max_mp: 0
      ),
      stats: Sunbird::ActorState::Stats.new(
        attack: 2
      )
    )

    session = Sunbird::Session.new(
      actors: { player: actor }
    )

    assert_nil session.party
    assert_equal actor, session.actor(:player)
  end

  def test_damage_and_healing_replace_actor_state
    session = test_session
    original = session.actor(:hero)

    damaged = session.damage_actor(:hero, 3)

    refute_same original, session.actor(:hero)
    assert_equal 7, damaged.hp
    assert_equal 7, session.actor(:hero).vitals.hp

    healed = session.heal_actor(:hero, 99)

    assert_equal 10, healed.hp
    assert_equal 10, session.actor(:hero).vitals.hp
  end

  def test_mp_spending_and_restoration_are_actor_state_changes
    session = test_session

    assert session.spend_actor_mp(:hero, 3)
    assert_equal 1, session.actor(:hero).vitals.mp

    refute session.spend_actor_mp(:hero, 2)
    assert_equal 1, session.actor(:hero).vitals.mp

    session.restore_actor_mp(:hero, 99)
    assert_equal 4, session.actor(:hero).vitals.mp
  end

  def test_party_members_require_persistent_actor_state
    party = Sunbird::Party.new(
      members: [:hero, :mage],
      leader: :hero
    )

    hero = Sunbird::ActorState.new(
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

    error = assert_raises(ArgumentError) do
      Sunbird::Session.new(
        party: party,
        actors: { hero: hero }
      )
    end

    assert_match "missing persistent actors", error.message
  end
end
