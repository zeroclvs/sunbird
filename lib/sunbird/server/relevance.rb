# frozen_string_literal: true

module Sunbird
  class Server
    class Relevance
      def relevant_instances(level:, world:)
        world.instance_ids
      end
    end
  end
end
