# frozen_string_literal: true

module Sunbird
  class AreaState
    class ComponentTable
      def initialize
        @entries = []
      end

      def [](instance_id)
        @entries[instance_id]
      end

      def []=(instance_id, value)
        validate_instance_id!(instance_id)
        @entries[instance_id] = value
      end

      def delete(instance_id)
        validate_instance_id!(instance_id)
        @entries[instance_id] = nil
      end

      private

      def validate_instance_id!(instance_id)
        return if instance_id.is_a?(Integer) && instance_id >= 0

        raise ArgumentError,
          "instance_id must be a non-negative Integer"
      end
    end
  end
end
