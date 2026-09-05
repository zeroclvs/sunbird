# frozen_string_literal: true

module Sunbird
  module Render
    class Selector
      VALID = %w[auto ascii kitty].freeze

      def self.build(capabilities:, env: ENV, assets: nil)
        requested = env.fetch(
          "SUNBIRD_RENDERER",
          "auto"
        ).downcase

        unless VALID.include?(requested)
          raise ArgumentError,
            "unknown renderer: #{requested.inspect}"
        end

        use_kitty = case requested
        when "kitty"
          true
        when "ascii"
          false
        else
          capabilities.graphics_protocol == :kitty
        end

        return Ascii.new unless use_kitty

        Kitty.new(
          assets: assets || AssetCatalog.default
        )
      end
    end
  end
end
