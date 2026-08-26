# frozen_string_literal: true

require "io/console"

module Sunbird
  module Host
    class TerminalListener
      ARROW_KEYS = {
        "\e[A" => :up,
        "\e[B" => :down,
        "\e[C" => :right,
        "\e[D" => :left
      }.freeze

      LETTER_KEYS = {
        "w" => :w,
        "W" => :w,
        "a" => :a,
        "A" => :a,
        "s" => :s,
        "S" => :s,
        "d" => :d,
        "D" => :d,
        "q" => :q,
        "Q" => :q
      }.freeze

      def initialize(input: $stdin)
        @input = input
      end

      def read_event
        first = @input.getch

        return LETTER_KEYS[first] unless first == "\e"

        sequence =
          first + @input.getch + @input.getch

        ARROW_KEYS[sequence]
      end
    end
  end
end
