module Layout
  module Cards
    class ToolsComponent < ApplicationComponent
      renders_one :badge, ->(*args, **kwargs) do
        Elements::BadgeComponent.new(*args, **kwargs.merge({ classes: 'bg-teal-medium text-blue-very-dark text-uppercase mb-3 f9' }))
      end
      renders_one :statement, ->(**kwargs) do
        Elements::HeaderComponent.new(**kwargs.merge({ classes: 'statement text-white card-text', level: 6 }))
      end
    end
  end
end
