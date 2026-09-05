# frozen_string_literal: true

module Sunbird
  module Host
    class Terminal
      CLEAR_SCREEN = "\e[2J\e[H"
      ERASE_LINE = "\e[2K"
      HIDE_CURSOR = "\e[?25l"
      SHOW_CURSOR = "\e[?25h"
      ENTER_ALT_SCREEN = "\e[?1049h"
      EXIT_ALT_SCREEN = "\e[?1049l"
      BEGIN_SYNC_UPDATE = "\e[?2026h"
      END_SYNC_UPDATE = "\e[?2026l"

      attr_reader :capabilities

      def initialize(
        input: $stdin,
        output: $stdout,
        input_adapter: nil,
        env: ENV
      )
        @output = output
        @input_adapter = input_adapter || TerminalInput.new(input: input)
        @capabilities = TerminalCapabilities.detect(env: env)
      end

      def read_event
        @input_adapter.read_event
      end

      def enter_application
        write(
          ENTER_ALT_SCREEN +
          CLEAR_SCREEN +
          HIDE_CURSOR
        )
      end

      def leave_application
        write(
          SHOW_CURSOR +
          EXIT_ALT_SCREEN
        )
      end

      def begin_synchronized_update
        write(BEGIN_SYNC_UPDATE)
      end

      def end_synchronized_update
        write(END_SYNC_UPDATE)
      end

      def clear
        write(CLEAR_SCREEN)
      end

      def write_status(row:, text:)
        write(
          "\e[#{row};1H" +
          ERASE_LINE +
          text
        )
      end

      def write(text)
        @output.write(text)
        @output.flush
      end
    end
  end
end
