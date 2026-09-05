# frozen_string_literal: true

require_relative "test_helper"

class InputMapperTest < Minitest::Test
  def test_escape_maps_to_quit
    action = Sunbird::Input::Mapper.new.map(:escape)

    assert_equal :quit, action.kind
    assert_equal :pressed, action.state
  end
end
