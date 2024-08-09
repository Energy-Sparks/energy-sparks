RSpec.shared_examples_for 'an application component' do
  it 'has additional classes on root element' do
    expect(html).to have_css("div.#{described_class.name.underscore.dasherize}.#{expected_classes}")
  end

  it 'has an id' do
    expect(html).to have_css("##{expected_id}")
  end
end
