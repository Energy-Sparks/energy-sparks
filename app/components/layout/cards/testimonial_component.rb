module Layout
  module Cards
    class TestimonialComponent < LayoutComponent
      renders_one :header, ->(**kwargs) do
        Elements::HeaderComponent.new(**kwargs.merge({ level: 4 }))
      end
      renders_one :quote, ->(**kwargs) do
        Elements::TagComponent.new(:q, **kwargs.merge({ classes: 'small' }))
      end
      renders_one :source, ->(**kwargs) do
        Elements::TagComponent.new(:p, **kwargs.merge({ classes: 'small text-blue-very-dark' }))
      end
      renders_many :buttons, ->(*args, **kwargs) do
        Elements::ButtonComponent.new(*args, **kwargs.merge({ classes: 'mb-1 mr-2' }))
      end
    end
  end
end
