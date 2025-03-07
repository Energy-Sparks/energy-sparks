module Layout
  class CarouselComponent < ApplicationComponent
    attr_reader :show_arrows

    renders_many :panels, types: {
      equivalence: { renders: ->(**kwargs) { EquivalenceComponent.new(**with_classes(**kwargs)) }, as: :equivalence },
      grid: { renders: ->(**kwargs) { Layout::GridComponent.new(**with_classes(**kwargs)) }, as: :grid }
    }

    def with_classes(**kwargs)
      kwargs[:classes] = class_names(kwargs[:classes], 'carousel-item', ('active' if panels.count.zero?))
      kwargs
    end

    def initialize(show_arrows: :bottom, show_markers: true, **_kwargs)
      super
      @show_arrows = show_arrows
      @show_markers = show_markers

      add_classes('side') if show_arrows == :side
    end

    def show_markers?
      @show_markers
    end

    def render?
      panels.any?
    end

    class ArrowComponent < ApplicationComponent
      def initialize(direction:, **_kwargs)
        super
        @direction = direction
      end

      def call
        tag.a(class: class_names("carousel-control-#{@direction}", classes), href: "##{id}", role: 'button', 'data-slide': @direction) do
          tag.span(class: "carousel-control-#{@direction}-icon", 'aria-hidden': true) +
            tag.span(class: 'sr-only') do
              @direction == :next ? t('common.labels.next') : t('common.labels.previous')
            end
        end
      end
    end
  end
end
