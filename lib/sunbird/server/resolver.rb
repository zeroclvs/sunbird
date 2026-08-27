# frozen_string_literal: true

module Sunbird
  class Server
    class Resolver
      def resolve(world:, level:, commands:)
        commands.each do |command|
          case command
          in Commands::Move
            resolve_move(
              world,
              level,
              command
            )
          in Commands::Attack
            resolve_attack(
              world,
              command
            )
          else
            raise ArgumentError,
              "unsupported command: #{command.inspect}"
          end
        end
      end

      private

      def resolve_move(world, level, command)
        position = world.component(
          command.instance,
          :position
        )
        return unless position

        next_x = position.x + command.dx
        next_y = position.y + command.dy

        return unless level.passable?(
          next_x,
          next_y
        )

        return if occupied?(
          world,
          next_x,
          next_y,
          except: command.instance
        )

        world.set_component(
          command.instance,
          :position,
          World::Position.new(
            x: next_x,
            y: next_y
          )
        )
      end


      def resolve_attack(world, command)
        health = world.component(
          command.target,
          :health
        )
        return unless health

        current = [health.current - command.damage, 0].max

        world.set_component(
          command.target,
          :health,
          World::Health.new(
            current: current,
            max: health.max
          )
        )
      end

      def occupied?(world, x, y, except:)
        world.instance_ids.any? do |instance_id|
          next false if instance_id == except

          collision = world.component(
            instance_id,
            :collision
          )

          next false unless (
            collision &&
            collision.blocks_movement
          )

          position = world.component(
            instance_id,
            :position
          )

          next false unless position

          position.x == x &&
            position.y == y
        end
      end
    end
  end
end
