# frozen_string_literal: true

require_relative "sunbird/version"

require_relative "sunbird/content/ruby_source"

require_relative "sunbird/world/components"
require_relative "sunbird/world/component_table"
require_relative "sunbird/world/relations"
require_relative "sunbird/world/view"
require_relative "sunbird/world"

require_relative "sunbird/entity"
require_relative "sunbird/entity/catalog"
require_relative "sunbird/entity/loader"

require_relative "sunbird/level"
require_relative "sunbird/level/terrain"
require_relative "sunbird/level/loader"

require_relative "sunbird/input/action"
require_relative "sunbird/input/mapper"
require_relative "sunbird/input/handoff"
require_relative "sunbird/input/snapshot"

require_relative "sunbird/server/commands"
require_relative "sunbird/server/relevance"
require_relative "sunbird/server/movement"
require_relative "sunbird/server/pathfinder"
require_relative "sunbird/server/planner"
require_relative "sunbird/server/resolver"
require_relative "sunbird/server"

require_relative "sunbird/render/frame"
require_relative "sunbird/render/projector"
require_relative "sunbird/render/ascii"

require_relative "sunbird/host/terminal"
require_relative "sunbird/host/terminal_input"

require_relative "sunbird/app"
