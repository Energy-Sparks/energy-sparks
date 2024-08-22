# Handles layout of an block showing a school equivalence
#
# Supports two layouts: a "horizontal" layout which is the original design
# with basically a two column view
#
# The vertical layout has the content stacked, so suitable for making a
# two column view of equivalences
class EquivalenceComponent < ApplicationComponent
  attr_reader :image_name

  renders_one :equivalence
  renders_one :title
  renders_one :header

  def initialize(image_name:, show_fuel: false, layout: :horizontal, id: nil, classes: '')
    super(id: id, classes: classes)
    @image_name = image_name
    @show_fuel = show_fuel
    @layout = layout.to_sym
  end

  def show_fuel?
    @show_fuel
  end

  def horizontal?
    @layout == :horizontal
  end

  def show_image?
    image_name.to_sym != :no_image
  end
end
