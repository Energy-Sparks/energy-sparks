module Layout
  class CarouselComponent < ApplicationComponent
    renders_many :panels, types: {
      equivalence: { renders: ->(**kwargs) { EquivalenceComponent.new(**with_classes(**kwargs)) }, as: :equivalence },
      grid: { renders: ->(**kwargs) { Layout::GridComponent.new(**with_classes(**kwargs)) }, as: :grid }
    }

    def with_classes(**kwargs)
      kwargs[:classes] = class_names(kwargs[:classes], 'carousel-item', ('active' if panels.count.zero?))
      kwargs
    end

    def initialize(show_arrows: true, show_markers: true, **_kwargs)
      super

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
      panels.any?
    end
  end
end
