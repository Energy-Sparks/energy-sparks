class EquivalenceCarouselComponent < ApplicationComponent
  renders_many :equivalences, EquivalenceComponent

  def initialize(id:, show_arrows: true, show_markers: true, classes: '')
    super(id: id, classes: classes)
    @show_arrows = show_arrows
    @show_markers = show_markers
  end

  def show_arrows?
    @show_arrows
  end

  def show_markers?
    @show_markers
  end

  def render?
    equivalences.any?
  end
end
