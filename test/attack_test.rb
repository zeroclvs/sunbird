# frozen_string_literal: true

require_relative "test_helper"

class AttackTest < Minitest::Test
  def setup
    @level = Sunbird::Level.new(
      name: :test,
      terrain: Sunbird::Level::Terrain.new(
        width: 5,
        height: 5
      ),
      spawns: [],
      relations: [],
      entry_spawn: nil
    )
  end

  def test_adjacent_attack_reduces_local_health
    area = Sunbird::AreaState.new

    attacker_id = area.spawn(
      position: Sunbird::AreaState::Position.new(
        x: 1,
        y: 1
      )
    )
    target_id = area.spawn(
      position: Sunbird::AreaState::Position.new(
        x: 2,
        y: 1
      ),
      health: Sunbird::AreaState::Health.new(
        current: 10,
        max: 10
      )
    )

    effects = resolve(
      area,
      Sunbird::Simulation::Commands::Attack.new(
        attacker_id: attacker_id,
        target_id: target_id,
        damage: 1
      )
    )

    assert_equal 9, area.component(target_id, :health).current
    assert_empty effects
  end

  def test_adjacent_attack_on_bound_actor_emits_persistent_damage
    area = Sunbird::AreaState.new

    attacker_id = area.spawn(
      position: Sunbird::AreaState::Position.new(
        x: 1,
        y: 1
      )
    )
    target_id = area.spawn(
      position: Sunbird::AreaState::Position.new(
        x: 2,
        y: 1
      ),
      actor_ref: Sunbird::AreaState::ActorRef.new(
        actor_key: :hero
      )
    )

    effects = resolve(
      area,
      Sunbird::Simulation::Commands::Attack.new(
        attacker_id: attacker_id,
        target_id: target_id,
        damage: 2
      )
    )

    assert_equal 1, effects.length
    effect = effects.first

    assert_instance_of Sunbird::Effects::DamageActor, effect
    assert_equal :hero, effect.actor_key
    assert_equal 2, effect.amount
    assert_nil area.component(target_id, :health)
  end

  def test_resolver_rejects_attack_when_target_is_not_adjacent
    area = Sunbird::AreaState.new

    attacker_id = area.spawn(
      position: Sunbird::AreaState::Position.new(
        x: 1,
        y: 1
      )
    )
    target_id = area.spawn(
      position: Sunbird::AreaState::Position.new(
        x: 3,
        y: 1
      ),
      health: Sunbird::AreaState::Health.new(
        current: 10,
        max: 10
      )
    )

    effects = resolve(
      area,
      Sunbird::Simulation::Commands::Attack.new(
        attacker_id: attacker_id,
        target_id: target_id,
        damage: 1
      )
    )

    assert_equal 10, area.component(target_id, :health).current
    assert_empty effects
  end

  private

  def resolve(area, command)
    Sunbird::Simulation::Resolver.new.resolve(
      area: area,
      level: @level,
      commands: Sunbird::Simulation::Commands::Buffer.new(
        [command]
      )
    )
  end
end
