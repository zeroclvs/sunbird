# frozen_string_literal: true

module Sunbird
  class AreaState
    class View
      def initialize(area_state)
        @area_state = area_state
      end

      def instance?(instance_id)
        @area_state.instance?(instance_id)
      end

      def instance_ids
        @area_state.instance_ids
      end

      def component(instance_id, name)
        @area_state.component(instance_id, name)
      end

      def relation_targets(kind:, source_id:)
        @area_state.relation_targets(
          kind: kind,
          source_id: source_id
        )
      end
    end
  end
end
