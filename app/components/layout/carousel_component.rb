# frozen_string_literal: true

module Layout
  class CarouselComponent < LayoutComponent
    attr_reader :show_arrows, :show_markers

    renders_many :panels, types: {
      equivalence: { renders: ->(**kwargs) { EquivalenceComponent.new(**with_classes(**kwargs)) }, as: :equivalence },
      grid: { renders: ->(**kwargs) { Layout::GridComponent.new(**with_classes(**kwargs)) }, as: :grid },
      testimonial_card: { renders: ->(**kwargs) { Cards::TestimonialComponent.new(**with_classes(**kwargs)) }, as: :testimonial_card },
      case_study_card: { renders: ->(**kwargs) { Cards::CaseStudyComponent.new(**with_classes(**kwargs)) }, as: :case_study_card }
    }

    def with_classes(**kwargs)
      kwargs[:classes] = class_names(kwargs[:classes], 'carousel-item', ('active' if panels.none?))
      kwargs
    end

    def initialize(show_arrows: :bottom, show_markers: true, **_kwargs)
      super
      @show_arrows = show_arrows
      @show_markers = show_markers
    end

    def before_render
      add_classes(show_arrows) if %i[side bottom].include?(show_arrows) && panels.length > 1
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
        tag.button(class: class_names("carousel-control-#{@direction}", classes),
                   href: "##{id}", type: 'button',
                   data: { slide: @direction, bs_slide: @direction, target: "##{id}", bs_target: "##{id}" }) do
          tag.span(class: "carousel-control-#{@direction}-icon", 'aria-hidden': true) +
            tag.span(class: 'visually-hidden') do
              @direction == :next ? t('common.labels.next') : t('common.labels.previous')
            end
        end
      end
    end
  end
end
