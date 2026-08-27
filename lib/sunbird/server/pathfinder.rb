# frozen_string_literal: true

module Sunbird
  class Server
    class Pathfinder
      DIRECTIONS = [
        [0, -1].freeze,
        [1, 0].freeze,
        [0, 1].freeze,
        [-1, 0].freeze
      ].freeze

      def next_step(level:, world:, source_id:, target_id:)
        source = world.component(source_id, :position)
        target = world.component(target_id, :position)
        return unless source && target

        start = [source.x, source.y].freeze
        blocked = blocking_positions(world, except: source_id)
        goals = adjacent_goals(level, target, blocked, start)
        return if goals.empty? || goals.key?(start)

        first_step = search(
          level: level,
          start: start,
          target: target,
          goals: goals,
          blocked: blocked
        )
        return unless first_step

        [first_step[0] - source.x, first_step[1] - source.y]
      end

      private

      def adjacent_goals(level, target, blocked, start)
        DIRECTIONS.each_with_object({}) do |(dx, dy), goals|
          x = target.x + dx
          y = target.y + dy
          position = [x, y].freeze

          next unless level.passable?(x, y)
          next if blocked.key?(position) && position != start

          goals[position] = true
        end
      end

      def blocking_positions(world, except:)
        world.instance_ids.each_with_object({}) do |instance_id, blocked|
          next if instance_id == except

          collision = world.component(instance_id, :collision)
          next unless collision&.blocks_movement

          position = world.component(instance_id, :position)
          next unless position

          blocked[[position.x, position.y].freeze] = true
        end
      end

      def search(level:, start:, target:, goals:, blocked:)
        queue = [start]
        head = 0
        parents = { start => nil }

        while head < queue.length
          current = queue[head]
          head += 1

          return first_step(parents, current, start) if goals.key?(current)

          ordered_directions(current, target).each do |dx, dy|
            neighbor = [current[0] + dx, current[1] + dy].freeze

            next if parents.key?(neighbor)
            next unless level.passable?(neighbor[0], neighbor[1])
            next if blocked.key?(neighbor)

            parents[neighbor] = current
            queue << neighbor
          end
        end

        nil
      end

      def ordered_directions(position, target)
        DIRECTIONS.sort_by.with_index do |(dx, dy), index|
          x = position[0] + dx
          y = position[1] + dy
          distance = (target.x - x).abs + (target.y - y).abs

          [distance, index]
        end
      end

      def first_step(parents, goal, start)
        step = goal

        while parents[step] && parents[step] != start
          step = parents[step]
        end

        step == start ? nil : step
      end
    end
  end
end
