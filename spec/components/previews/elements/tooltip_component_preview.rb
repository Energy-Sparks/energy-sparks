module Elements
  class TooltipComponentPreview < ViewComponent::Preview
    def default
      render(Elements::TooltipComponent.new('Tooltip text')) do
        'Hover over me'
      end
    end
  end
end
