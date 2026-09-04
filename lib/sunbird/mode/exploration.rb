# frozen_string_literal: true

module Sunbird
  module Mode
    class Exploration
      attr_reader :simulation

      def initialize(simulation:)
        @simulation = simulation
      end

      def advance(input:)
        return :quit if input.pressed?(:quit)

        commands = simulation.plan(input: input)
        simulation.step(commands: commands)
        :advanced
      end

      def level
        simulation.level
      end

      def world_view
        simulation.world_view
      end

      def step_number
        simulation.step_number
      end
    end
  end
end
