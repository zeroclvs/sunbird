# frozen_string_literal: true

require "stringio"
require_relative "test_helper"

class HostTerminalTest < Minitest::Test
  FakeInput = Struct.new(:event) do
    def read_event
      event
    end
  end

  def test_terminal_owns_transport_and_reports_protocol_capabilities
    output = StringIO.new
    host = Sunbird::Host::Terminal.new(
      output: output,
      input_adapter: FakeInput.new(:right)
    )

    assert_equal :right, host.read_event
    assert_nil host.capabilities.graphics_protocol
    assert_equal :legacy, host.capabilities.keyboard_protocol
  end
end
