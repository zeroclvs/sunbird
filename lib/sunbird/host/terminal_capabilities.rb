# frozen_string_literal: true

module Sunbird
  module Host
    class TerminalCapabilities
      KITTY_TERMS = [
        "xterm-kitty",
        "kitty"
      ].freeze

      def self.detect(env: ENV)
        graphics_protocol = if kitty_graphics?(env)
          :kitty
        end

        Capabilities.new(
          graphics_protocol: graphics_protocol,
          keyboard_protocol: :legacy
        )
      end

      def self.kitty_graphics?(env)
        return true if present?(env["KITTY_WINDOW_ID"])

        term = env["TERM"].to_s.downcase
        KITTY_TERMS.any? { |name| term.include?(name) }
      end
      private_class_method :kitty_graphics?

      def self.present?(value)
        value && !value.empty?
      end
      private_class_method :present?
    end
  end
end
