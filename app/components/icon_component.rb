# Displays a font awesome icon. See preview for examples of usage
#
# Provides a simple way to insert two types of icon (plain icon and centered in a
# white circle) into a page. Icons can be resized to match our font sizes. Additional
# classes can be provided to allow for further customisation
class IconComponent < ApplicationComponent
  include ApplicationHelper

  attr_reader :style, :fuel_type, :classes, :icon_set

  def initialize(name: nil, size: 'f5', fuel_type: nil, fixed_width: false, icon_set: 'fas', style: :default, classes: '')
    super(classes: classes)

    raise 'Unknown icon style' unless [:default, :circle].include?(style)
    @name = name
    @fuel_type = fuel_type
    @style = style
    @icon_set = icon_set
    add_classes(size)
    add_classes('fa-fw') if fixed_width
  end

  def icon_name
    dasherize_name || fuel_type_icon(@fuel_type)
  end

  private

  def dasherize_name
    @name&.to_s&.dasherize
  end
end
