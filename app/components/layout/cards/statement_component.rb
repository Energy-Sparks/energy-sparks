module Layout
  module Cards
    class StatementComponent < LayoutComponent
      renders_one :badge, ->(*args, **kwargs) do
        Elements::BadgeComponent.new(*args, **{ classes: 'bg-teal-medium text-blue-very-dark text-uppercase mb-3' }.merge(kwargs))
      end
      renders_one :statement, ->(**kwargs) do
        Elements::HeaderComponent.new(**{ classes: 'statement text-white card-text', level: 6 }.merge(kwargs))
      end
    end
  end
end
