# frozen_string_literal: true

module Sunbird
  module Level
    module Sources
      TestField = Definition.new(
        name: :test_field,

        tiles: {
          " " => Tile.new(
            glyph: " ",
            passable: true
          ),
          '"' => Tile.new(
            glyph: '"',
            passable: true
          ),
          "~" => Tile.new(
            glyph: "~",
            passable: false
          ),
          "|" => Tile.new(
            glyph: "|",
            passable: false
          ),
          "_" => Tile.new(
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
            entity: :player,
            x: 3,
            y: 3
          ),
          Spawn.new(
            entity: :goblin,
            x: 35,
            y: 3
          ),
          Spawn.new(
            entity: :goblin,
            x: 14,
            y: 10
          ),
          Spawn.new(
            entity: :goblin,
            x: 32,
            y: 11
          )
        ].freeze
      )
    end
  end
end
