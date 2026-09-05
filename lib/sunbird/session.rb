# frozen_string_literal: true

module Sunbird
  class Session
    attr_reader :party

    def initialize(party:)
      @party = party
    end
  end
end
