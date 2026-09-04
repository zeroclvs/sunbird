# frozen_string_literal: true

module Sunbird
  class Entity
    module Loader
      module_function

      def load(path)
        absolute_path = File.expand_path(path)

        unless File.extname(absolute_path) == ".rb"
          raise ArgumentError,
            "unsupported entity source: #{absolute_path}"
        end

        require absolute_path

        definition_name = constant_name_for(absolute_path)
        definitions = Definitions.const_get(definition_name, false)

        Catalog.new(definitions)
      end

      def constant_name_for(path)
        File.basename(path, ".rb")
          .split("_")
          .map!(&:capitalize)
          .join
      end
      private_class_method :constant_name_for
    end
  end
end
