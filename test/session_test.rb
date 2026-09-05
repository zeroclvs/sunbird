# frozen_string_literal: true

require_relative "test_helper"

class SessionTest < Minitest::Test
  include SunbirdTestSupport

  def test_session_owns_party_and_persistent_vitals
    session = test_session

    assert_equal [:hero, :mage], session.party.members

    hero = session.vitals(:hero)
    assert_equal 10, hero.hp
    assert_equal 10, hero.max_hp
    assert_equal 4, hero.mp
    assert_equal 4, hero.max_mp
  end

  def test_damage_and_healing_replace_persistent_vitals
    session = test_session
    original = session.vitals(:hero)

    damaged = session.damage(:hero, 3)

    refute_same original, damaged
    assert_equal 7, damaged.hp
    assert_equal 7, session.vitals(:hero).hp

    healed = session.heal(:hero, 99)

    assert_equal 10, healed.hp
    assert_equal 10, session.vitals(:hero).hp
  end

  def test_damage_clamps_at_zero
    session = test_session

    session.damage(:hero, 99)

    assert_equal 0, session.vitals(:hero).hp
  end

  def test_mp_spending_and_restoration_are_session_owned
    session = test_session

    assert session.spend_mp(:hero, 3)
    assert_equal 1, session.vitals(:hero).mp

    refute session.spend_mp(:hero, 2)
    assert_equal 1, session.vitals(:hero).mp

    session.restore_mp(:hero, 99)
    assert_equal 4, session.vitals(:hero).mp
  end

  def test_session_requires_vitals_for_every_party_member
    party = Sunbird::Party.new(
      members: [:hero, :mage],
      leader: :hero
    )

    error = assert_raises(ArgumentError) do
      Sunbird::Session.new(
        party: party,
        vitals: {
          hero: Sunbird::Session::Vitals.new(
            hp: 10,
            max_hp: 10,
            mp: 4,
            max_mp: 4
          )
        }
      )
    end

    assert_match "missing session vitals", error.message
  end

  def test_session_rejects_invalid_vital_ranges
    party = Sunbird::Party.new(
      members: [:hero],
      leader: :hero
    )

    error = assert_raises(ArgumentError) do
      Sunbird::Session.new(
        party: party,
        vitals: {
          hero: Sunbird::Session::Vitals.new(
            hp: 11,
            max_hp: 10,
            mp: 0,
            max_mp: 0
          )
        }
      )
    end

    assert_match "hp is outside", error.message
  end
end
