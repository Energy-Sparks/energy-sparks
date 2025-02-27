RSpec.shared_examples_for 'an application component' do
  let(:component_class_name) { described_class.name.underscore.dasherize.parameterize }

  it 'has the expected class on the first occurrence' do
    expect(html).to have_css(":first-child.#{component_class_name}.#{expected_classes}")
  end

  it 'has an id' do
    expect(html).to have_css("##{expected_id}")
  end
end
