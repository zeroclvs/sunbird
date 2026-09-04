# frozen_string_literal: true

module Sunbird
  module Host
    class Terminal
      CLEAR_SCREEN = "\e[2J\e[H"
      HIDE_CURSOR = "\e[?25l"
      SHOW_CURSOR = "\e[?25h"

      attr_reader :capabilities

      def initialize(input: $stdin, output: $stdout, input_adapter: nil)
        @output = output
        @input_adapter = input_adapter || TerminalInput.new(input: input)
        @capabilities = Capabilities.new(
          graphics_protocol: nil,
          keyboard_protocol: :legacy
        )
      end

      def read_event
        @input_adapter.read_event
      end

      def clear
        write(CLEAR_SCREEN)
      end

      def hide_cursor
        write(HIDE_CURSOR)
      end

      def show_cursor
        write(SHOW_CURSOR)
      end

      def write(text)
        @output.write(text)
        @output.flush
      end
    end
  end
end
