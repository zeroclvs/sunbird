# frozen_string_literal: true

require_relative "test_helper"

class SessionTest < Minitest::Test
  def test_session_owns_party_above_level_local_simulation
    party = Sunbird::Party.new(
      members: [:hero, :mage],
      leader: :hero
    )
    session = Sunbird::Session.new(party: party)

    assert_same party, session.party
  end
end
