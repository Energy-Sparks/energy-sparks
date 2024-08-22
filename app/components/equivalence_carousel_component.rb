class EquivalenceCarouselComponent < ApplicationComponent
  renders_many :equivalences, EquivalenceComponent

  def initialize(id:, classes: '')
    super(id: id, classes: classes)
  end
end
