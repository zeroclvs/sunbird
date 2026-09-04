# frozen_string_literal: true

require_relative "test_helper"

class ComponentTableTest < Minitest::Test
  def test_values_are_indexed_by_instance_id
    table = Sunbird::World::ComponentTable.new
    position = Sunbird::World::Position.new(x: 2, y: 3)

    table[7] = position

    assert_equal position, table[7]
    assert_nil table[6]
  end

  def test_negative_instance_id_is_rejected
    table = Sunbird::World::ComponentTable.new

    assert_raises(ArgumentError) do
      table[-1] = :invalid
    end
  end
end
