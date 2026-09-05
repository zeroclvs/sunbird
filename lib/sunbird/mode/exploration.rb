# frozen_string_literal: true

module Sunbird
  module Mode
    class Exploration
      attr_reader :simulation, :session

      def initialize(simulation:, session:)
        @simulation = simulation
        @session = session
        @party_instances = bind_party_leader.freeze
      end

      def advance(input:)
        return :quit if input.pressed?(:quit)

        commands = simulation.plan(
          input: input,
          controlled_id: controlled_instance_id
        )
        simulation.step(commands: commands)
        :advanced
      end

      def level
        simulation.level
      end

      def world_view
        simulation.world_view
      end

      def step_number
        simulation.step_number
      end

      def controlled_instance_id
        @party_instances.fetch(session.party.leader)
      end

      def instance_id_for_party_member(member)
        @party_instances[member.to_sym]
      end

      private

      def bind_party_leader
        entry_spawn = simulation.level.entry_spawn
        unless entry_spawn
          raise ArgumentError,
            "exploration level has no entry spawn"
        end

        {
          session.party.leader => simulation.instance_id_for_spawn(entry_spawn)
        }
      end
    end
  end
end
