# frozen_string_literal: true

module Sunbird
  class Session
    Vitals = Data.define(
      :hp,
      :max_hp,
      :mp,
      :max_mp
    )

    attr_reader :party

    def initialize(party:, vitals:)
      @party = party
      @vitals = normalize_vitals(vitals)
      validate_party_vitals!
    end

    def vitals(member)
      @vitals.fetch(normalize_member(member))
    end

    def damage(member, amount)
      validate_amount!(amount)

      current = vitals(member)
      replace_vitals(
        member,
        hp: [current.hp - amount, 0].max,
        mp: current.mp
      )
    end

    def heal(member, amount)
      validate_amount!(amount)

      current = vitals(member)
      replace_vitals(
        member,
        hp: [current.hp + amount, current.max_hp].min,
        mp: current.mp
      )
    end

    def spend_mp(member, amount)
      validate_amount!(amount)

      current = vitals(member)
      return false if amount > current.mp

      replace_vitals(
        member,
        hp: current.hp,
        mp: current.mp - amount
      )
      true
    end

    def restore_mp(member, amount)
      validate_amount!(amount)

      current = vitals(member)
      replace_vitals(
        member,
        hp: current.hp,
        mp: [current.mp + amount, current.max_mp].min
      )
    end

    private

    def normalize_vitals(vitals)
      unless vitals.is_a?(Hash)
        raise ArgumentError, "session vitals must be a Hash"
      end

      vitals.to_h do |member, value|
        normalized_member = normalize_member(member)
        validate_vitals!(normalized_member, value)
        [normalized_member, value]
      end
    end

    def validate_party_vitals!
      missing = party.members.reject { |member| @vitals.key?(member) }
      unless missing.empty?
        raise ArgumentError,
          "missing session vitals for: #{missing.inspect}"
      end

      unknown = @vitals.keys.reject { |member| party.include?(member) }
      unless unknown.empty?
        raise ArgumentError,
          "session vitals contain non-party members: #{unknown.inspect}"
      end
    end

    def validate_vitals!(member, value)
      unless value.is_a?(Vitals)
        raise ArgumentError,
          "invalid vitals for #{member.inspect}: #{value.inspect}"
      end

      values = [
        value.hp,
        value.max_hp,
        value.mp,
        value.max_mp
      ]
      unless values.all? { |number| number.is_a?(Integer) }
        raise ArgumentError,
          "vitals must use integer values for #{member.inspect}"
      end

      unless value.max_hp.positive?
        raise ArgumentError,
          "max_hp must be positive for #{member.inspect}"
      end

      if value.max_mp.negative?
        raise ArgumentError,
          "max_mp must not be negative for #{member.inspect}"
      end

      unless value.hp.between?(0, value.max_hp)
        raise ArgumentError,
          "hp is outside 0..max_hp for #{member.inspect}"
      end

      unless value.mp.between?(0, value.max_mp)
        raise ArgumentError,
          "mp is outside 0..max_mp for #{member.inspect}"
      end
    end

    def validate_amount!(amount)
      return if amount.is_a?(Integer) && amount >= 0

      raise ArgumentError,
        "vital change amount must be a non-negative Integer"
    end

    def normalize_member(member)
      member.to_sym
    end

    def replace_vitals(member, hp:, mp:)
      key = normalize_member(member)
      current = vitals(key)

      replacement = Vitals.new(
        hp: hp,
        max_hp: current.max_hp,
        mp: mp,
        max_mp: current.max_mp
      )
      validate_vitals!(key, replacement)
      @vitals[key] = replacement
      replacement
    end
  end
end
