# frozen_string_literal: true

module Sunbird
  class Simulation
    class Relevance
      def relevant_instances(level:, world:)
        world.instance_ids
      end
    end
  end
end
