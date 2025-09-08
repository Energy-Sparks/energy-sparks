module Layout
  module Cards
    class StatementComponent < LayoutComponent
      renders_one :badge, ->(*args, **kwargs) do
        Elements::BadgeComponent.new(*args, **{ classes: 'text-uppercase mb-3 font-weight-normal' }.merge(kwargs))
      end
      renders_one :statement, ->(**kwargs) do
        Elements::TagComponent.new(:p, **{ classes: 'statement card-text text-main' }.merge(kwargs))
      end
    end
  end
end
