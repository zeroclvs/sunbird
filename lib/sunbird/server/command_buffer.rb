# frozen_string_literal: true

module Sunbird
  class Server
    class CommandBuffer
      include Enumerable

      def initialize(commands)
        @commands = commands.freeze
      end

      def each(&block)
        @commands.each(&block)
      end

      def empty?
        @commands.empty?
      end

      def size
        @commands.size
      end
    end
  end
end
