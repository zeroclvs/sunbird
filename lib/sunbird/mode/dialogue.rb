# frozen_string_literal: true

module Sunbird
  module Mode
    class Dialogue
      attr_reader :parent_mode, :lines, :index

      def initialize(parent_mode:, lines:)
        if lines.empty?
          raise ArgumentError, "dialogue mode requires at least one line"
        end

        @parent_mode = parent_mode
        @lines = lines.dup.freeze
        @index = 0
      end

      def advance(input:)
        return :quit if input.pressed?(:quit)
        return :pop if input.pressed?(:cancel)
        return :waiting unless input.pressed?(:interact)

        if index == lines.length - 1
          :pop
        else
          @index += 1
          :advanced
        end
      end

      def current_line
        lines.fetch(index)
      end

      def level
        parent_mode.level
      end

      def world_view
        parent_mode.world_view
      end

      def step_number
        parent_mode.step_number
      end

      def status_text
        "#{current_line}  [Enter/Space]"
      end
    end
  end
end
