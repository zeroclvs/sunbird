# frozen_string_literal: true

require_relative "sunbird/version"

require_relative "sunbird/world/components"
require_relative "sunbird/world/component_table"
require_relative "sunbird/world/runtime_relations"
require_relative "sunbird/world/view"
require_relative "sunbird/world/world"

require_relative "sunbird/entity"
require_relative "sunbird/entity/registry"
require_relative "sunbird/entity/loader"

require_relative "sunbird/level/definition"
require_relative "sunbird/level/map"
require_relative "sunbird/level/loader"

require_relative "sunbird/input/action"
require_relative "sunbird/input/mapper"
require_relative "sunbird/input/handoff"
require_relative "sunbird/input/snapshot"

require_relative "sunbird/server/commands"
require_relative "sunbird/server/command_buffer"
require_relative "sunbird/server/activation"
require_relative "sunbird/server/pathfinder"
require_relative "sunbird/server/tick_builder"
require_relative "sunbird/server/resolver"
require_relative "sunbird/server/server"

require_relative "sunbird/render/frame"
require_relative "sunbird/render/projector"
require_relative "sunbird/render/ascii"

require_relative "sunbird/host/terminal"
require_relative "sunbird/host/terminal_listener"

require_relative "sunbird/app"
