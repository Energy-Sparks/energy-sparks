RSpec.shared_examples_for 'an application component' do
  let(:component_class_name) { described_class.name.underscore.dasherize.parameterize }

  it 'has the component class' do
    expect(html).to have_css(":first-child[class*='#{component_class_name}']")
  end

  it 'has the expected classes' do
    expected_classes.split(/[\s.]+/).each do |class_name|
      expect(html).to have_css(":first-child[class*='#{class_name}']")
    end
  end

  it 'has an id' do
    expect(html).to have_css(":first-child[id*='#{expected_id}']")
  end
end

RSpec.shared_examples_for 'a layout component' do
  it 'has the theme classes' do
    expect(html).to have_css(".theme.theme-#{expected_theme}")
  end
end
