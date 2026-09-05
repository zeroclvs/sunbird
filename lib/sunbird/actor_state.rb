# frozen_string_literal: true

module Sunbird
  class ActorState
    Vitals = Data.define(
      :hp,
      :max_hp,
      :mp,
      :max_mp
    )

    Stats = Data.define(
      :attack
    )

    attr_reader :vitals, :stats

    def initialize(vitals:, stats:)
      validate_vitals!(vitals)
      validate_stats!(stats)

      @vitals = vitals
      @stats = stats
      freeze
    end

    def with(vitals: @vitals, stats: @stats)
      self.class.new(
        vitals: vitals,
        stats: stats
      )
    end

    private

    def validate_vitals!(vitals)
      unless vitals.is_a?(Vitals)
        raise ArgumentError,
          "actor vitals must be ActorState::Vitals"
      end

      values = [
        vitals.hp,
        vitals.max_hp,
        vitals.mp,
        vitals.max_mp
      ]

      unless values.all? { |value| value.is_a?(Integer) }
        raise ArgumentError, "actor vitals must use integer values"
      end

      unless vitals.max_hp.positive?
        raise ArgumentError, "max_hp must be positive"
      end

      if vitals.max_mp.negative?
        raise ArgumentError, "max_mp must not be negative"
      end

      unless vitals.hp.between?(0, vitals.max_hp)
        raise ArgumentError, "hp is outside 0..max_hp"
      end

      unless vitals.mp.between?(0, vitals.max_mp)
        raise ArgumentError, "mp is outside 0..max_mp"
      end
    end

    def validate_stats!(stats)
      unless stats.is_a?(Stats)
        raise ArgumentError,
          "actor stats must be ActorState::Stats"
      end

      unless stats.attack.is_a?(Integer) && stats.attack >= 0
        raise ArgumentError,
          "attack must be a non-negative Integer"
      end
    end
  end
end
