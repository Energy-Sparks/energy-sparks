module Layout
  module Cards
    class FeatureComponentPreview < ViewComponent::Preview
      def xl
        render(Layout::Cards::FeatureComponent.new(theme: :dark, size: :xl, classes: 'p-3')) do |card|
          card.with_header title: 'I am extra large'
          card.with_description { 'Interesting text' }
          card.with_button 'Primary link', '/', style: :primary
          card.with_button 'Secondary link', '/', style: :secondary
        end
      end

      def lg
        render(Layout::Cards::FeatureComponent.new(theme: :light, size: :lg, classes: 'p-3')) do |card|
          card.with_header title: 'I am large'
          card.with_description { 'Interesting text' }
          card.with_button 'Primary link', '/', style: :primary
          card.with_button 'Secondary link', '/', style: :secondary
        end
      end

      def md
        render(Layout::Cards::FeatureComponent.new(theme: :light, size: :md, classes: 'p-3')) do |card|
          card.with_header title: 'I am medium'
          card.with_description { 'Interesting text' }
          card.with_button 'Primary link', '/', style: :primary
          card.with_button 'Secondary link', '/', style: :secondary
        end
      end

      def sm
        render(Layout::Cards::FeatureComponent.new(theme: :light, size: :sm, classes: 'p-3')) do |card|
          card.with_header title: 'I am small'
          card.with_description { 'Interesting text' }
          card.with_button 'Primary link', '/', style: :primary
          card.with_button 'Secondary link', '/', style: :secondary
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

      def with_price
        render(Layout::Cards::FeatureComponent.new(theme: :light, classes: 'p-3 rounded-xl')) do |card|
          card.with_tag('Rock bottom prices')
          card.with_header title: 'Header'
          card.with_price label: 'Starting from', price: '£2999 + VAT'
        end
      end

      def with_blog_fields
        render(Layout::Cards::FeatureComponent.new(theme: :light, classes: 'p-3 rounded-xl')) do |card|
          card.with_tag('Guidance')
          card.with_tag('Energy savings')
          card.with_tag('Reducing heating consumption')
          card.with_date(Time.zone.today)
          card.with_author(href: '/') { 'Happy Blogger' }
          card.with_header title: 'Header'
          card.with_description { 'Interesting text' }
          card.with_link(href: '/') { 'Read more' }
        end
      end

      def with_dark_theme
        render(Layout::Cards::FeatureComponent.new(theme: :dark, classes: 'p-3')) do |card|
          card.with_header title: 'Header'
          card.with_description { 'Interesting text' }
          card.with_button 'Primary link', '/', style: :primary
          card.with_button 'Secondary link', '/', style: :secondary
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
