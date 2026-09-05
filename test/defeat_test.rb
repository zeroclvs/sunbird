# frozen_string_literal: true

require_relative "test_helper"

class DefeatTest < Minitest::Test
  def setup
    @level = Sunbird::Level.new(
      name: :test,
      terrain: Sunbird::Level::Terrain.new(width: 5, height: 5),
      spawns: [],
      relations: [],
      entry_spawn: nil
    )
  end

  def test_defeat_retires_zero_health_instance
    world = Sunbird::World.new
    instance_id = world.spawn(
      health: Sunbird::World::Health.new(current: 0, max: 4),
      position: Sunbird::World::Position.new(x: 2, y: 2),
      renderable: Sunbird::World::Renderable.new(
        render_key: :goblin,
        glyph: "G",
        layer: 10
      ),
      behavior: Sunbird::World::Behavior.new(kind: :chase),
      collision: Sunbird::World::Collision.new(blocks_movement: true),
      combatant: Sunbird::World::Combatant.new(attack: 1)
    )

    resolve(
      world,
      Sunbird::Simulation::Commands::Defeat.new(instance_id: instance_id)
    )

    assert_equal 0, world.component(instance_id, :health).current
    assert_equal [2, 2], [
      world.component(instance_id, :position).x,
      world.component(instance_id, :position).y
    ]
    assert_nil world.component(instance_id, :renderable)
    assert_nil world.component(instance_id, :behavior)
    assert_nil world.component(instance_id, :collision)
    assert_nil world.component(instance_id, :combatant)
  end

  def test_defeat_does_nothing_while_health_is_positive
    world = Sunbird::World.new
    instance_id = world.spawn(
      health: Sunbird::World::Health.new(current: 1, max: 4),
      collision: Sunbird::World::Collision.new(blocks_movement: true)
    )

    resolve(
      world,
      Sunbird::Simulation::Commands::Defeat.new(instance_id: instance_id)
    )

    assert world.component(instance_id, :collision).blocks_movement
  end

  private

  def resolve(world, command)
    Sunbird::Simulation::Resolver.new.resolve(
      world: world,
      level: @level,
      commands: Sunbird::Simulation::Commands::Buffer.new([command])
    )
  end
end
