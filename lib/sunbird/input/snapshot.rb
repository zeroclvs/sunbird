# frozen_string_literal: true

module Sunbird
  module Input
    class Snapshot
      def self.from(actions)
        states = {}

        actions.each do |action|
          states[action.kind] = action.state
        end

        new(states)
      end

      def self.empty
        new({})
      end

      def initialize(states)
        @states = states.dup.freeze
      end

      def state(kind)
        @states[kind]
      end

      def pressed?(kind)
        state(kind) == :pressed
      end
    end
  end
end
