module Layout
  module Cards
    class StatementComponent < ApplicationComponent
      renders_one :header, ->(**kwargs) do
        Elements::HeaderComponent.new(**({ level: 3 }.merge(kwargs)))
      end
      renders_one :description, ->(**kwargs) do
        Elements::ParagraphComponent.new(**({ classes: 'small' }.merge(kwargs)))
      end

      def initialize(**_kwargs)
        super
        add_classes('p-4 m-4 text-center')
      end
    end
  end
end
