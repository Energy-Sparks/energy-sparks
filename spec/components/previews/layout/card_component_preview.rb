module Layout
  class CardComponentPreview < ViewComponent::Preview
    def with_all_options
      render Layout::CardComponent.new(theme: :light, classes: 'rounded') do |card|
        card.with_image(src: 'laptop.jpg')
        card.with_body { 'Body text' }
        card.with_list_group do
          '<li class="list-group-item">Item 1</li><li class="list-group-item">Item 2</li>'.html_safe
        end
        card.with_feature_card do |feature|
          feature.with_header title: 'Header'
          feature.with_description { 'Interesting text' }
          feature.with_button 'Primary link', '/', style: :primary
          feature.with_button 'Secondary link', '/', style: :secondary
        end
        card.with_footer { 'Footer text' }
      end
    end
  end
end
