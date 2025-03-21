module Layout
  module Cards
    class FeatureComponentPreview < ViewComponent::Preview
      def main
        render(Layout::Cards::FeatureComponent.new(theme: :dark, main: true, classes: 'p-3')) do |card|
          card.with_header title: 'Text should scale up on XL'
          card.with_description { 'Buttons should scale up a bit too!' }
          card.with_button 'Primary link', '/', style: :success
          card.with_button 'Secondary link', '/', style: :white, outline: true
        end
      end

      def normal
        render(Layout::Cards::FeatureComponent.new) do |card|
          card.with_header title: 'Header'
          card.with_description { 'Interesting text' }
          card.with_button 'Primary link', '/', style: :primary
          card.with_button 'Secondary link', '/', style: :secondary
        end
      end

      def with_dark_theme
        render(Layout::Cards::FeatureComponent.new(theme: :dark, classes: 'p-3')) do |card|
          card.with_header title: 'Header'
          card.with_description { 'Interesting text' }
          card.with_button 'Primary link', '/', style: :success
          card.with_button 'Secondary link', '/', style: :white, outline: true
        end
      end

      def with_light_theme
        render(Layout::Cards::FeatureComponent.new(theme: :light, classes: 'p-3')) do |card|
          card.with_header title: 'Header'
          card.with_description { 'Interesting text' }
          card.with_button 'Primary link', '/', style: :primary
          card.with_button 'Secondary link', '/', style: :secondary
        end
      end

      def with_accent_theme
        render(Layout::Cards::FeatureComponent.new(theme: :accent, classes: 'p-3')) do |card|
          card.with_header title: 'Header'
          card.with_description { 'Interesting text' }
          card.with_button 'Primary link', '/', style: :primary
          card.with_button 'Secondary link', '/', style: :secondary
        end
      end
    end
  end
end
