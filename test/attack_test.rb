# frozen_string_literal: true

require_relative "test_helper"

class AttackTest < Minitest::Test
  def setup
    @level = Sunbird::Level.new(
      name: :test,
      terrain: Sunbird::Level::Terrain.new(width: 5, height: 5),
      spawns: [],
      relations: [],
      controlled_spawn: nil
    )
  end

  def test_adjacent_attack_reduces_health
    world = Sunbird::World.new
    attacker_id = world.spawn(
      position: Sunbird::World::Position.new(x: 1, y: 1)
    )
    target_id = world.spawn(
      position: Sunbird::World::Position.new(x: 2, y: 1),
      health: Sunbird::World::Health.new(current: 10, max: 10)
    )

    commands = Sunbird::Server::Commands::Buffer.new(
      [
        Sunbird::Server::Commands::Attack.new(
          attacker_id: attacker_id,
          target_id: target_id,
          damage: 1
        )
      ]
    )

    Sunbird::Server::Resolver.new.resolve(
      world: world,
      level: @level,
      commands: commands
    )

    assert_equal 9, world.component(target_id, :health).current
  end

  def test_resolver_rejects_attack_when_target_is_no_longer_adjacent
    world = Sunbird::World.new
    attacker_id = world.spawn(
      position: Sunbird::World::Position.new(x: 1, y: 1)
    )
    target_id = world.spawn(
      position: Sunbird::World::Position.new(x: 3, y: 1),
      health: Sunbird::World::Health.new(current: 10, max: 10)
    )

    commands = Sunbird::Server::Commands::Buffer.new(
      [
        Sunbird::Server::Commands::Attack.new(
          attacker_id: attacker_id,
          target_id: target_id,
          damage: 1
        )
      ]
    )

    Sunbird::Server::Resolver.new.resolve(
      world: world,
      level: @level,
      commands: commands
    )

    assert_equal 10, world.component(target_id, :health).current
  end
end
