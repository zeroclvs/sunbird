# frozen_string_literal: true

require_relative "test_helper"

class AreaStateTest < Minitest::Test
  def test_area_state_is_canonical_local_runtime_container
    area = Sunbird::AreaState.new

    instance_id = area.spawn(
      position: Sunbird::AreaState::Position.new(
        x: 2,
        y: 3
      )
    )

    assert_equal [instance_id], area.instance_ids
    assert_equal(
      [2, 3],
      [
        area.component(instance_id, :position).x,
        area.component(instance_id, :position).y
      ]
    )
  end

  def test_world_constant_is_a_transitional_alias
    assert_same Sunbird::AreaState, Sunbird::World
  end
end
