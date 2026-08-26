# frozen_string_literal: true

module Sunbird
  module Render
    class Ascii
      def render(frame)
        frame.lines.join("\n")
      end
    end
  end
end
