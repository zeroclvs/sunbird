# frozen_string_literal: true

module Sunbird
  class Level
    module Definitions
      TestField = Definition.new(
        name: :test_field,

        tiles: {
          " " => Tile.new(
            render_key: :ground,
            glyph: " ",
            passable: true
          ),
          '"' => Tile.new(
            render_key: :grass,
            glyph: '"',
            passable: true
          ),
          "~" => Tile.new(
            render_key: :water,
            glyph: "~",
            passable: false
          ),
          "|" => Tile.new(
            render_key: :wall,
            glyph: "|",
            passable: false
          ),
          "_" => Tile.new(
            render_key: :wall,
            glyph: "_",
            passable: false
          )
        }.freeze,

        rows: [
          "____________________________________________",
          '|      """"                ~~~~~           |',
          '|   """""""              ~~~~~~~           |',
          '|                         ~~~~~            |',
          '|            """""                         |',
          '|       """"""""              ~~~~         |',
          '|                            ~~~~~~        |',
          '|     ~~~~~                  ~~~~~         |',
          '|    ~~~~~~~        """""                  |',
          '|     ~~~~~       """"""""                 |',
          '|                  """"             """"   |',
          '|        """"                        ""    |',
          '|                                          |',
          "____________________________________________"
        ].map!(&:freeze).freeze,

        spawns: [
          Spawn.new(
            key: :player,
            entity: :player,
            x: 3,
            y: 3
          ),
          Spawn.new(
            key: :goblin_a,
            entity: :goblin,
            x: 35,
            y: 3
          ),
          Spawn.new(
            key: :goblin_b,
            entity: :goblin,
            x: 14,
            y: 10
          ),
          Spawn.new(
            key: :goblin_c,
            entity: :goblin,
            x: 32,
            y: 11
          )
        ].freeze,

        relations: [
          Relation.new(
            kind: :targets,
            source: :goblin_a,
            target: :player
          ),
          Relation.new(
            kind: :targets,
            source: :goblin_b,
            target: :player
          ),
          Relation.new(
            kind: :targets,
            source: :goblin_c,
            target: :player
          )
        ].freeze,

        entry_spawn: :player
      )
    end
  end
end
