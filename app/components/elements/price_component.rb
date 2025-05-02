module Elements
  class PriceComponent < ApplicationComponent
    def initialize(label:, price:, level: 3, **_kwargs)
      super
      @label = label
      @price = price
      @level = level
      add_classes('pt-2')
    end

    def call
      tag.div(class: classes, id: id) do
        tag.div(@label + ':', class: 'smaller') +
          render(Elements::HeaderComponent.new(title: @price, **{ level: @level }.compact))
      end
    end
  end
end
