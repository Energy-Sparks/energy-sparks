RSpec.shared_examples_for 'a cms admin page' do
  it 'has links to all index pages' do
    expect(page).to have_link('Categories', href: admin_cms_categories_path)
    expect(page).to have_link('Pages', href: admin_cms_pages_path)
    expect(page).to have_link('Sections', href: admin_cms_sections_path)
  end
end
