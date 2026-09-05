# frozen_string_literal: true

require_relative "test_helper"

class BattleModeTest < Minitest::Test
  include SunbirdTestSupport

  def setup
    level = level_with(
      spawns: [
        Sunbird::Level::Spawn.new(
          key: :hero,
          entity: :player,
          x: 2,
          y: 2
        ),
        Sunbird::Level::Spawn.new(
          key: :goblin,
          entity: :goblin,
          x: 3,
          y: 2
        )
      ],
      entry_spawn: :hero
    )
    simulation = Sunbird::Simulation.new(
      level: level,
      entities: actor_catalog
    )
    @session = test_session
    @exploration = Sunbird::Mode::Exploration.new(
      simulation: simulation,
      session: @session,
      dialogues: dialogue_catalog
    )
    @enemy_id = simulation.instance_id_for_spawn(:goblin)
    @battle = Sunbird::Mode::Battle.new(
      parent_mode: @exploration,
      enemy_id: @enemy_id
    )
  end

  def test_attack_turn_damages_enemy_world_and_party_session
    result = @battle.advance(input: action_input(:interact))

    assert_equal :advanced, result
    assert_equal 1, @battle.step_number
    assert_equal 2, enemy_health.current
    assert_equal 9, @session.vitals(:hero).hp

    hero_id = @exploration.controlled_instance_id
    assert_nil @battle.world_view.component(hero_id, :health)
  end

  def test_winning_turn_pops_without_enemy_retaliation
    @battle.advance(input: action_input(:interact))

    result = @battle.advance(input: action_input(:interact))

    assert_equal :pop, result
    assert_equal 2, @battle.step_number
    assert_equal 0, enemy_health.current
    assert_equal 9, @session.vitals(:hero).hp
    assert_nil @battle.world_view.component(@enemy_id, :renderable)
    assert_nil @battle.world_view.component(@enemy_id, :collision)
    assert_nil @battle.world_view.component(@enemy_id, :behavior)
    assert_nil @battle.world_view.component(@enemy_id, :combatant)
  end

  def test_damage_persists_after_return_to_exploration
    @battle.advance(input: action_input(:interact))
    @battle.advance(input: action_input(:cancel))

    assert_equal 9, @session.vitals(:hero).hp
    assert_match "Hero HP 9/10", @exploration.status_text
  end

  def test_cancel_flees_without_new_damage_or_simulation_step
    result = @battle.advance(input: action_input(:cancel))

    assert_equal :pop, result
    assert_equal 0, @battle.step_number
    assert_equal 4, enemy_health.current
    assert_equal 10, @session.vitals(:hero).hp
  end

  def test_status_text_uses_session_hp_and_mp
    assert_match "Hero HP 10/10 MP 4/4", @battle.status_text
    assert_match "Goblin HP 4/4", @battle.status_text
  end

  private

  def enemy_health
    @battle.world_view.component(@enemy_id, :health)
  end
end
