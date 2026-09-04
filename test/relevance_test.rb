# frozen_string_literal: true

require_relative "test_helper"

class RelevanceTest < Minitest::Test
  def test_current_policy_selects_all_instances
    world = Sunbird::World.new
    first = world.spawn
    second = world.spawn

    relevant = Sunbird::Server::Relevance.new.relevant_instances(
      level: nil,
      world: world.view
    )

    assert_equal [first, second], relevant
  end
end
