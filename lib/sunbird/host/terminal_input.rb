# frozen_string_literal: true

require "io/wait"

module Sunbird
  module Host
    class TerminalInput
      ESCAPE = "\e"
      ESCAPE_TIMEOUT = 0.04
      MAX_ESCAPE_BYTES = 24

      SIMPLE_KEYS = {
        "w" => :w,
        "W" => :w,
        "a" => :a,
        "A" => :a,
        "s" => :s,
        "S" => :s,
        "d" => :d,
        "D" => :d,
        "q" => :q,
        "Q" => :q,
        "\r" => :enter,
        "\n" => :enter,
        " " => :space,
        "\u0003" => :q
      }.freeze

      ARROW_FINALS = {
        "A" => :up,
        "B" => :down,
        "C" => :right,
        "D" => :left
      }.freeze

      def initialize(input: $stdin, escape_timeout: ESCAPE_TIMEOUT)
        @input = input
        @escape_timeout = escape_timeout
      end

      def read_event
        first = read_byte
        return unless first

        mapped = SIMPLE_KEYS[first]
        return mapped if mapped
        return unless first == ESCAPE

        read_escape_event
      end

      private

      def read_escape_event
        return :escape unless continuation_available?

        sequence = +ESCAPE
        next_byte = read_byte
        return :escape unless next_byte

        sequence << next_byte
        return unless sequence.end_with?("[", "O")

        while sequence.bytesize < MAX_ESCAPE_BYTES
          return decode_escape(sequence) if escape_complete?(sequence)
          break unless continuation_available?

          byte = read_byte
          break unless byte

          sequence << byte
        end

        decode_escape(sequence)
      end

      def read_byte
        @input.read(1)
      end

      def continuation_available?
        if @input.respond_to?(:wait_readable)
          !!@input.wait_readable(@escape_timeout)
        elsif @input.respond_to?(:eof?)
          !@input.eof?
        else
          true
        end
      end

      def escape_complete?(sequence)
        return false if sequence.bytesize < 3

        final = sequence.getbyte(-1)
        final && final.between?(0x40, 0x7e)
      end

      def decode_escape(sequence)
        match = sequence.match(/\A\e(?:\[[0-9;:?]*|O)([ABCD])\z/)
        return unless match

        ARROW_FINALS[match[1]]
      end
    end
  end
end
