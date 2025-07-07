module Elements
  class PriceComponent < ApplicationComponent
    def initialize(label:, price:, subtext: nil, level: 4, **_kwargs)
      super
      @label = label
      @price = price
      @level = level
      @subtext = subtext
      add_classes('pt-2')
    end

    def call
      tag.div(class: classes, id: id) do
        tag.div(@label + ':', class: 'smaller') +
          render(Elements::HeaderComponent.new(title: @price, **{ level: @level, classes: 'mb-0' }.compact)) +
          (tag.div(@subtext, class: 'f8') if @subtext.present?)
      end
    end
  end
end
