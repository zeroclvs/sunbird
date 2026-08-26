# frozen_string_literal: true

module Sunbird
  module Host
    class Terminal
      CLEAR_SCREEN = "\e[2J\e[H"
      HIDE_CURSOR = "\e[?25l"
      SHOW_CURSOR = "\e[?25h"

      def initialize(output: $stdout)
        @output = output
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
