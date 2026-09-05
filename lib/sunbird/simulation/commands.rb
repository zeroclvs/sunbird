# frozen_string_literal: true

module Sunbird
  class Simulation
    module Commands
      Move = Data.define(:instance_id, :dx, :dy)
      Attack = Data.define(:attacker_id, :target_id, :damage)
      Defeat = Data.define(:instance_id)

      class Buffer
        include Enumerable

        def initialize(commands)
          @commands = commands.freeze
        end

        def each(&block)
          @commands.each(&block)
        end

        def empty?
          @commands.empty?
        end

        def size
          @commands.size
        end
      end
    end
  end
end
