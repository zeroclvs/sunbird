# frozen_string_literal: true

module Sunbird
  class Level
    class Terrain
      DEFAULT_TILES = {
        " " => Tile.new(
          glyph: " ",
          passable: true
        )
      }.freeze

      attr_reader :width, :height

      def initialize(width: nil, height: nil, rows: nil, tiles: nil)
        if rows
          initialize_from_rows(
            rows,
            tiles || DEFAULT_TILES
          )
        else
          initialize_blank(width, height)
        end
      end

      def inside?(x, y)
        x.between?(0, width - 1) &&
          y.between?(0, height - 1)
      end

      def glyph_at(x, y)
        return unless inside?(x, y)

        @rows[y][x]
      end

      def passable?(x, y)
        return false unless inside?(x, y)

        @tiles.fetch(glyph_at(x, y)).passable
      end

      private

      def initialize_blank(width, height)
        unless width.is_a?(Integer) && width.positive?
          raise ArgumentError,
            "width must be a positive Integer"
        end

        unless height.is_a?(Integer) && height.positive?
          raise ArgumentError,
            "height must be a positive Integer"
        end

        @width = width
        @height = height
        @tiles = DEFAULT_TILES
        @rows = Array.new(height) do
          (" " * width).freeze
        end.freeze
      end

      def initialize_from_rows(rows, tiles)
        raise ArgumentError, "rows cannot be empty" if rows.empty?

        frozen_rows = rows.map do |row|
          String(row).dup.freeze
        end

        width = frozen_rows.first.length

        unless width.positive? &&
               frozen_rows.all? { |row| row.length == width }
          raise ArgumentError,
            "all terrain rows must have the same non-zero width"
        end

        frozen_tiles = tiles.dup.freeze
        unknown = frozen_rows.flat_map(&:chars).uniq -
          frozen_tiles.keys

        unless unknown.empty?
          raise ArgumentError,
            "unknown terrain glyphs: #{unknown.inspect}"
        end

        @width = width
        @height = frozen_rows.length
        @rows = frozen_rows.freeze
        @tiles = frozen_tiles
      end
    end
  end
end
