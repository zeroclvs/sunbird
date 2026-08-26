# frozen_string_literal: true

require_relative "test_helper"

class ActivationTest < Minitest::Test
  def test_current_policy_activates_all_instances
    world = Sunbird::World.new

    first = world.spawn
    second = world.spawn

    active = Sunbird::Server::Activation.new
      .active_instances(
        level: Sunbird::Level::Map.new(
          width: 2,
          height: 2
        ),
        world: world.view
      )

    assert_equal [first, second], active
  end
end
