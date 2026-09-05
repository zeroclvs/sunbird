# frozen_string_literal: true

require_relative "test_helper"

class PartyTest < Minitest::Test
  def test_party_keeps_stable_member_identities_and_leader
    party = Sunbird::Party.new(
      members: [:hero, :mage],
      leader: :hero
    )

    assert_equal [:hero, :mage], party.members
    assert_equal :hero, party.leader
    assert party.include?(:mage)
  end

  def test_party_rejects_unknown_leader
    error = assert_raises(ArgumentError) do
      Sunbird::Party.new(
        members: [:hero],
        leader: :mage
      )
    end

    assert_equal "unknown party leader: :mage", error.message
  end

  def test_party_rejects_duplicate_members
    assert_raises(ArgumentError) do
      Sunbird::Party.new(
        members: [:hero, :hero],
        leader: :hero
      )
    end
  end
end
