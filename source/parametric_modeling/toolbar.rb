# Parametric Modeling extension for SketchUp.
# Copyright: © 2021 Samuel Tallet <samuel.tallet arobase gmail.com>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3.0 of the License, or
# (at your option) any later version.
# 
# If you release a modified version of this program TO THE PUBLIC,
# the GPL requires you to MAKE THE MODIFIED SOURCE CODE AVAILABLE
# to the program's users, UNDER THE GPL.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
# 
# Get a copy of the GPL here: https://www.gnu.org/licenses/gpl.html

require 'sketchup'
require 'fileutils'
require 'parametric_modeling/nodes_editor'

# Parametric Modeling plugin namespace.
module ParametricModeling

  # Connects this plugin toolbar to SketchUp user interface.
  module Toolbar

    # Absolute path to "Toolbar Icons" directory.
    ICONS_DIR = File.join(__dir__, 'Toolbar Icons')

    private_constant :ICONS_DIR

    # Gets toolbar icon extension depending on platform.
    #
    # @return [String]
    def self.icon_extension
      Sketchup.platform == :platform_osx ? '.pdf' : '.svg'
    end

    # Adds toolbar.
    def self.add

      toolbar = UI::Toolbar.new(NAME)

      command = UI::Command.new('one') { NodesEditor.open }

      command.small_icon = command.large_icon = File.join(ICONS_DIR, 'one' + icon_extension)
      command.tooltip = TRANSLATE['Open Nodes Editor']

      toolbar.add_item(command)

      toolbar.show

    end

  end

end
