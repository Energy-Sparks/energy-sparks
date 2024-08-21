# Handles formatting of an equivalence created by interpolating school Equivalence data
# with formatting in EquivalenceType.
class EquivalenceComponent < ApplicationComponent
  attr_reader :image_name

  renders_one :equivalence
  renders_one :title
  renders_one :header

  def initialize(image_name:, id: nil, classes: '')
    super(id: id, classes: classes)
    @image_name = image_name
  end

  def show_image?
    image_name.to_sym != :no_image
  end
end
