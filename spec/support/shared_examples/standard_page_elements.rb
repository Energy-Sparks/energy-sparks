RSpec.shared_examples "a page with breadcrumbs" do |breadcrumbs|

  it "displays breadcrumbs" do
    expect(find('ol.main-breadcrumbs').all('li').collect(&:text)).to eq(breadcrumbs)
  end
end
