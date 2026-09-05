# frozen_string_literal: true

module Sunbird
  class Party
    attr_reader :members, :leader

    def initialize(members:, leader:)
      normalized_members = members.map(&:to_sym)

      raise ArgumentError, "party must have at least one member" if normalized_members.empty?
      if normalized_members.uniq.length != normalized_members.length
        raise ArgumentError, "party members must be unique"
      end

      normalized_leader = leader.to_sym
      unless normalized_members.include?(normalized_leader)
        raise ArgumentError,
          "unknown party leader: #{normalized_leader.inspect}"
      end

      @members = normalized_members.freeze
      @leader = normalized_leader
    end

    def include?(member)
      @members.include?(member.to_sym)
    end
  end
end
