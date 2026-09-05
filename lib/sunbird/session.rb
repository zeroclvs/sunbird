# frozen_string_literal: true

module Sunbird
  class Session
    # Transitional alias for v0.3 callers. New v0.4 code should use
    # ActorState::Vitals directly.
    Vitals = ActorState::Vitals

    attr_reader :party

    def initialize(actors:, party: nil)
      @actors = normalize_actors(actors)
      @party = party
      validate_party_actors! if party
    end

    def actor(actor_key)
      @actors.fetch(normalize_actor_key(actor_key))
    end

    def actor_keys
      @actors.keys.freeze
    end

    def vitals(actor_key)
      actor(actor_key).vitals
    end

    def stats(actor_key)
      actor(actor_key).stats
    end

    def apply_effect(effect)
      case effect
      in Effects::DamageActor
        damage_actor(
          effect.actor_key,
          effect.amount
        )
      else
        raise ArgumentError,
          "unsupported persistent effect: #{effect.inspect}"
      end
    end

    def apply_effects(effects)
      effects.each do |effect|
        apply_effect(effect)
      end
    end

    def damage_actor(actor_key, amount)
      validate_amount!(amount)

      current = actor(actor_key)
      vitals = current.vitals

      replace_actor_vitals(
        actor_key,
        hp: [vitals.hp - amount, 0].max,
        mp: vitals.mp
      )
    end

    def heal_actor(actor_key, amount)
      validate_amount!(amount)

      current = actor(actor_key)
      vitals = current.vitals

      replace_actor_vitals(
        actor_key,
        hp: [vitals.hp + amount, vitals.max_hp].min,
        mp: vitals.mp
      )
    end

    def spend_actor_mp(actor_key, amount)
      validate_amount!(amount)

      current = actor(actor_key)
      vitals = current.vitals
      return false if amount > vitals.mp

      replace_actor_vitals(
        actor_key,
        hp: vitals.hp,
        mp: vitals.mp - amount
      )
      true
    end

    def restore_actor_mp(actor_key, amount)
      validate_amount!(amount)

      current = actor(actor_key)
      vitals = current.vitals

      replace_actor_vitals(
        actor_key,
        hp: vitals.hp,
        mp: [vitals.mp + amount, vitals.max_mp].min
      )
    end

    # v0.3 compatibility names.
    alias damage damage_actor
    alias heal heal_actor
    alias spend_mp spend_actor_mp
    alias restore_mp restore_actor_mp

    private

    def normalize_actors(actors)
      unless actors.is_a?(Hash)
        raise ArgumentError, "session actors must be a Hash"
      end

      normalized = {}

      actors.each do |actor_key, state|
        key = normalize_actor_key(actor_key)

        if normalized.key?(key)
          raise ArgumentError,
            "duplicate persistent actor: #{key.inspect}"
        end

        unless state.is_a?(ActorState)
          raise ArgumentError,
            "invalid actor state for #{key.inspect}: #{state.inspect}"
        end

        normalized[key] = state
      end

      normalized
    end

    def validate_party_actors!
      missing = party.members.reject do |member|
        @actors.key?(member)
      end

      return if missing.empty?

      raise ArgumentError,
        "missing persistent actors for party members: #{missing.inspect}"
    end

    def validate_amount!(amount)
      return if amount.is_a?(Integer) && amount >= 0

      raise ArgumentError,
        "actor state change amount must be a non-negative Integer"
    end

    def normalize_actor_key(actor_key)
      actor_key.to_sym
    end

    def replace_actor_vitals(actor_key, hp:, mp:)
      key = normalize_actor_key(actor_key)
      current = actor(key)
      vitals = current.vitals

      replacement_vitals = ActorState::Vitals.new(
        hp: hp,
        max_hp: vitals.max_hp,
        mp: mp,
        max_mp: vitals.max_mp
      )

      replacement = current.with(
        vitals: replacement_vitals
      )

      @actors[key] = replacement
      replacement.vitals
    end
  end
end
