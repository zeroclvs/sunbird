# frozen_string_literal: true

require_relative "test_helper"

class RenderSceneTest < Minitest::Test
  def test_ascii_renderer_consumes_backend_neutral_scene
    scene = Sunbird::Render::Scene.new(
      width: 3,
      height: 2,
      tiles: [
        Sunbird::Render::Scene::Tile.new(
          x: 0,
          y: 0,
          render_key: :ground,
          fallback_glyph: "."
        ),
        Sunbird::Render::Scene::Tile.new(
          x: 1,
          y: 0,
          render_key: :ground,
          fallback_glyph: "."
        ),
        Sunbird::Render::Scene::Tile.new(
          x: 2,
          y: 0,
          render_key: :ground,
          fallback_glyph: "."
        ),
        Sunbird::Render::Scene::Tile.new(
          x: 0,
          y: 1,
          render_key: :ground,
          fallback_glyph: "."
        ),
        Sunbird::Render::Scene::Tile.new(
          x: 1,
          y: 1,
          render_key: :ground,
          fallback_glyph: "."
        ),
        Sunbird::Render::Scene::Tile.new(
          x: 2,
          y: 1,
          render_key: :ground,
          fallback_glyph: "."
        )
      ],
      instances: [
        Sunbird::Render::Scene::Instance.new(
          instance_id: 7,
          x: 1,
          y: 0,
          render_key: :hero,
          fallback_glyph: "P",
          layer: 10
        )
      ]
    )

    assert_equal ".P.\n...", Sunbird::Render::Ascii.new.render(scene)
    assert_equal 7, scene.instances.first.instance_id
    assert_equal :hero, scene.instances.first.render_key
  end
end
