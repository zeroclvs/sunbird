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

require_relative "sunbird/simulation/commands"
require_relative "sunbird/simulation/relevance"
require_relative "sunbird/simulation/movement"
require_relative "sunbird/simulation/pathfinder"
require_relative "sunbird/simulation/planner"
require_relative "sunbird/simulation/resolver"
require_relative "sunbird/simulation"

require_relative "sunbird/mode_stack"
require_relative "sunbird/mode/exploration"

require_relative "sunbird/render/scene"
require_relative "sunbird/render/projector"
require_relative "sunbird/render/ascii"

require_relative "sunbird/host"
require_relative "sunbird/host/terminal_input"
require_relative "sunbird/host/terminal"

require_relative "sunbird/app"
