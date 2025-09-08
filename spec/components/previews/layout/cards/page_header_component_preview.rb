module Layout
  module Cards
    class PageHeaderComponentPreview < ViewComponent::Preview
      # @param theme "Theme" select { choices: [pale, accent, light, dark] }
      # @param title "Title" text
      # @param subtitle "Subtitle" text
      def default(theme: :pale, title: 'Page title', subtitle: 'Page subtitle')
        render(Layout::Cards::PageHeaderComponent.new(theme:, title:, subtitle:))
      end

      # @param theme "Theme" select { choices: [pale, accent, light, dark] }
      # @param title "Title" text
      # @param subtitle "Subtitle" text
      # @param callout_title "Callout Title" text
      # @param callout_background "Callout Background Class" select { choices: [bg-white, bg-grey-pale]}
      def callout(theme: :pale, title: 'Page title', subtitle: 'Page subtitle', callout_title: 'Callout', callout_background: 'bg-white')
        render(Layout::Cards::PageHeaderComponent.new(theme:, title:, subtitle:)) do |card|
          card.with_callout(title: callout_title, classes: callout_background) do |callout|
            callout.with_row do
              tag.span('callout content')
            end
          end
        end
      end
    end
  end
end
