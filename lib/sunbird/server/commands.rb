# frozen_string_literal: true

module Sunbird
  class Server
    module Commands
      Move = Data.define(
        :instance,
        :dx,
        :dy
      )

      Attack = Data.define(
        :attacker,
        :target,
        :damage
      )
    end
  end
end
