# Displays a font awesome icon. See preview for examples of usage
#
# Provides a simple way to insert two types of icon (plain icon and centered in a
# white circle) into a page. Icons can be resized to match our font sizes. Additional
# classes can be provided to allow for further customisation
class IconComponent < ViewComponent::Base
  include ApplicationHelper

  attr_reader :style, :size, :fuel_type, :classes

  def initialize(name: nil, size: 'f5', fuel_type: nil, fixed_width: false, style: :default, classes: '')
    raise 'Unknown icon style' unless [:default, :circle].include?(style)
    @name = name
    @size = size
    @fuel_type = fuel_type
    @style = style
    @classes = "#{classes} #{size} #{'fa-fw' if fixed_width}"
  end

  def icon_name
    @name || fuel_type_icon(@fuel_type)
  end
end
