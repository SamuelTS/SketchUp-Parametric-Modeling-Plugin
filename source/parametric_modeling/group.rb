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
require 'parametric_modeling/number'

# Parametric Modeling plugin namespace.
module ParametricModeling

  # SketchUp group.
  module Group

    # Flattens a group or a component (grouponent).
    #
    # Code of this method is based on dezmo's `merge_groups` function.
    # @see https://forums.sketchup.com/t/how-to-merge-groups/145530/2
    #
    # @param [Sketchup::Group, Sketchup::ComponentInstance] grouponent
    # @raise [ArgumentError]
    #
    # @return [Sketchup::Group] Flattened grouponent.
    def self.flatten(grouponent)

      raise ArgumentError, 'Grouponent must be a Sketchup::Group|ComponentInstance.'\
        unless [Sketchup::Group, Sketchup::ComponentInstance].include?(grouponent.class)
      
      flattened_group = Sketchup.active_model.entities.add_group([grouponent])

      flattened_group.entities.each do |entity|
        entity.explode if entity.respond_to?(:explode)
      end

      flattened_group

    end

    # Gets points of a group.
    #
    # @param [Sketchup::Group] group
    # @raise [ArgumentError]
    #
    # @return [Array] Points grouped by face and ordered...
    def self.points(group)

      raise ArgumentError, 'Group must be a Sketchup::Group.'\
        unless group.is_a?(Sketchup::Group)
      
      group_points = []
      group_transformation = group.transformation
      group_faces = group.entities.grep(Sketchup::Face)

      group_faces.each do |group_face|

        group_face_points = []

        group_face.outer_loop.vertices.each do |group_face_vertex|

          group_face_point = group_face_vertex.position
          group_face_point.transform!(group_transformation)

          group_face_points.push([

            Number.from_ul(group_face_point.x),
            Number.from_ul(group_face_point.y),
            Number.from_ul(group_face_point.z)
            
          ])

        end

        group_points.push(group_face_points)

      end

      group_points

    end

    # Push/Pull faces of a group.
    #
    # @param [Sketchup::Group] group
    # @param [Length] distance
    # @param [Geom::Vector3d] direction
    # @raise [ArgumentError]
    #
    # @return [Sketchup::Group]
    def self.pushpull(group, distance, direction)

      raise ArgumentError, 'Group must be a Sketchup::Group.'\
        unless group.is_a?(Sketchup::Group)

      raise ArgumentError, 'Distance must be a Length.'\
        unless distance.is_a?(Length)

      raise ArgumentError, 'Direction must be a Geom::Vector3d.'\
        unless direction.is_a?(Geom::Vector3d)

      group_faces_to_pushpull = []
      group_faces = group.entities.grep(Sketchup::Face)

      # If no direction was specified:
      if direction == Geom::Vector3d.new(0, 0, 0)
        # Then, all group faces will be pushed/pulled to their respective direction.
        group_faces_to_pushpull = group_faces
      else

        group_faces.each do |group_face|
          group_faces_to_pushpull.push(group_face) if group_face.normal == direction
        end

      end

      group_faces_to_pushpull.each do |group_face_to_pushpull|
        group_face_to_pushpull.pushpull(distance)
      end

      group

    end

    # Moves a group.
    #
    # @param [Sketchup::Group] group
    # @param [Geom::Point3d] point
    # @raise [ArgumentError]
    #
    # @return [Sketchup::Group]
    def self.move(group, point)

      raise ArgumentError, 'Group must be a Sketchup::Group.'\
        unless group.is_a?(Sketchup::Group)

      raise ArgumentError, 'Point must be a Geom::Point3d.'\
        unless point.is_a?(Geom::Point3d)

      group.transform!(Geom::Transformation.translation(point))

      group

    end

    # Rotates a group.
    #
    # @param [Sketchup::Group] group
    # @param [Geom::Point3d] center
    # @param [Geom::Vector3d] axis
    # @param [Integer, Float] angle
    # @raise [ArgumentError]
    #
    # @return [Sketchup::Group]
    def self.rotate(group, center, axis, angle)

      raise ArgumentError, 'Group must be a Sketchup::Group.'\
        unless group.is_a?(Sketchup::Group)

      raise ArgumentError, 'Center must be a Geom::Point3d.'\
        unless center.is_a?(Geom::Point3d)

      raise ArgumentError, 'Axis must be a Geom::Vector3d.'\
        unless axis.is_a?(Geom::Vector3d)

      raise ArgumentError, 'Angle must be an Integer or a Float.'\
        unless angle.is_a?(Integer) || angle.is_a?(Float)

      group.transform!(Geom::Transformation.rotation(center, axis, angle.degrees))

      group

    end

    # Scales a group.
    #
    # @param [Sketchup::Group] group
    # @param [Geom::Point3d] point
    # @param [Integer, Float] x_factor
    # @param [Integer, Float] y_factor
    # @param [Integer, Float] z_factor
    # @raise [ArgumentError]
    #
    # @return [Sketchup::Group]
    def self.scale(group, point, x_factor, y_factor, z_factor)

      raise ArgumentError, 'Group must be a Sketchup::Group.'\
        unless group.is_a?(Sketchup::Group)

      raise ArgumentError, 'Point must be a Geom::Point3d.'\
        unless point.is_a?(Geom::Point3d)

      raise ArgumentError, 'X factor must be an Integer or a Float.'\
        unless x_factor.is_a?(Integer) || x_factor.is_a?(Float)

      raise ArgumentError, 'Y factor must be an Integer or a Float.'\
        unless y_factor.is_a?(Integer) || y_factor.is_a?(Float)

      raise ArgumentError, 'Z factor must be an Integer or a Float.'\
        unless z_factor.is_a?(Integer) || z_factor.is_a?(Float)

      group.transform!(Geom::Transformation.scaling(point, x_factor, y_factor, z_factor))

      group

    end

    # Copies a group. Name, material and layer are also copied.
    #
    # @param [Sketchup::Group] group
    # @raise [ArgumentError]
    #
    # @return [Sketchup::Group] Copied group.
    def self.copy(group)

      raise ArgumentError, 'Group must be a Sketchup::Group.'\
        unless group.is_a?(Sketchup::Group)
  
      copied_group = group.copy
      copied_group.set_attribute(CODE_NAME, 'isParametric', true)

      copied_group.name = group.name
      copied_group.material = group.material
      copied_group.layer = group.layer

      copied_group

    end

    # Makes a group.
    #
    # @param [Array<Sketchup::Group>] groups
    # @param [String] name
    # @param [Sketchup::Material, nil] material
    # @param [Sketchup::Layer, nil] layer
    # @raise [ArgumentError]
    #
    # @return [Sketchup::Group]
    def self.make(groups, name, material, layer)

      raise ArgumentError, 'Groups must be an Array.'\
        unless groups.is_a?(Array)

      raise ArgumentError, 'Name must be a String.'\
        unless name.is_a?(String)
  
      raise ArgumentError, 'Material must be a Sketchup::Material or nil.'\
        unless material.is_a?(Sketchup::Material) || material.nil?
  
      raise ArgumentError, 'Layer must be a Sketchup::Layer or nil.'\
        unless layer.is_a?(Sketchup::Layer) || layer.nil?

      group = Sketchup.active_model.entities.add_group(groups)
      group.set_attribute(CODE_NAME, 'isParametric', true)

      group.name = name
      group.material = material
      group.layer = layer

      group

    end

  end

end
