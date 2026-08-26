# frozen_string_literal: true

require_relative "test_helper"

class InputHandoffTest < Minitest::Test
  def test_events_after_handoff_belong_to_next_batch
    handoff = Sunbird::Input::Handoff.new

    east = Sunbird::Input::Action.new(
      kind: :move_east,
      state: :pressed
    )

    north = Sunbird::Input::Action.new(
      kind: :move_north,
      state: :pressed
    )

    handoff.push(east)
    handoff.flip!
    handoff.push(north)

    assert_equal(
      [east],
      handoff.take_completed
    )

    handoff.flip!

    assert_equal(
      [north],
      handoff.take_completed
    )
  end
end
