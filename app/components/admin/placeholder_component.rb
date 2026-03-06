module Admin
  class PlaceholderComponent < Elements::TooltipComponent
    def initialize(text = nil, **kwargs)
      super("Placeholder: #{text || 'please replace me'}", **kwargs)
    end
  end
end
