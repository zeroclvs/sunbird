# frozen_string_literal: true

module Sunbird
  class ActorBindings
    Binding = Data.define(
      :actor_key,
      :instance_id
    )

    include Enumerable

    def initialize(bindings = {})
      unless bindings.is_a?(Hash)
        raise ArgumentError, "actor bindings must be a Hash"
      end

      @bindings = {}

      bindings.each do |actor_key, instance_id|
        key = normalize_actor_key(actor_key)
        validate_instance_id!(instance_id)

        if @bindings.key?(key)
          raise ArgumentError,
            "duplicate actor binding: #{key.inspect}"
        end

        @bindings[key] = Binding.new(
          actor_key: key,
          instance_id: instance_id
        )
      end

      @bindings.freeze
    end

    def [](actor_key)
      @bindings[normalize_actor_key(actor_key)]&.instance_id
    end

    def fetch(actor_key)
      @bindings.fetch(
        normalize_actor_key(actor_key)
      ).instance_id
    end

    def binding(actor_key)
      @bindings.fetch(normalize_actor_key(actor_key))
    end

    def key?(actor_key)
      @bindings.key?(normalize_actor_key(actor_key))
    end

    def each(&block)
      return enum_for(:each) unless block

      @bindings.each_value(&block)
    end

    private

    def normalize_actor_key(actor_key)
      actor_key.to_sym
    end

    def validate_instance_id!(instance_id)
      return if instance_id.is_a?(Integer) && instance_id >= 0

      raise ArgumentError,
        "instance_id must be a non-negative Integer"
    end
  end
end
