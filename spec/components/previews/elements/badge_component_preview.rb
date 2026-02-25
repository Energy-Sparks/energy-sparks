module Elements
  class BadgeComponentPreview < ViewComponent::Preview
    def with_content_no_style
      render(Elements::BadgeComponent.new) do
        'Badge'
      end
    end

    def with_text_and_style
      render(Elements::BadgeComponent.new('Badge - success', colour: :success))
    end

    def badge_pill
      render(Elements::BadgeComponent.new('Badge pill - warning', pill: true, colour: :warning))
    end
  end
end
