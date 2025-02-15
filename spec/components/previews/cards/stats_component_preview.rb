module Cards
  class StatsComponentPreview < ViewComponent::Preview
    def without_classes
      render(Cards::StatsComponent.new) do |card|
        card.with_icon fuel_type: :electricity, style: :circle
        card.with_header 'Header'
        card.with_figure '90%'
        card.with_subtext { 'Interesting text about the above figure' }
      end
    end
  end
end
