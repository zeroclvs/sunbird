# frozen_string_literal: true

module Sunbird
  class Server
    module Commands
      Move = Data.define(
        :instance,
        :dx,
        :dy
      )
    end
  end
end
