module Layout
  class CardComponent < LayoutComponent
    renders_many :elements, types: types(
      type(:image, Elements::ImageComponent, fit: false, classes: 'card-img-top'),
      type(:body, Elements::TagComponent, :div, classes: 'card-body'),
      type(:list_group, Elements::TagComponent, :ul, classes: 'list-group list-group-flush'),
      type(:feature_card, Cards::FeatureComponent, classes: 'card-body p-4'),
      type(:footer, Elements::TagComponent, :div, classes: 'card-footer'),
    )

    def initialize(*_args, **_kwargs)
      super
      add_classes('card border-0')
    end

    def call
      tag.div(id: id, class: classes) do
        safe_join(elements)
      end
    end

    def render?
      elements.any?
    end
  end
end
