RSpec.shared_examples_for 'a cms admin page' do
  it 'has links to all index pages' do
    expect(page).to have_link('Categories', href: admin_cms_categories_path)
    expect(page).to have_link('Pages', href: admin_cms_pages_path)
    expect(page).to have_link('Sections', href: admin_cms_sections_path)
  end
end

RSpec.shared_examples_for 'a publishable model' do
  it 'allows model to be published and unpublished', :js do
    accept_confirm do
      click_link('Publish')
    end

    expect(page).to have_content('Content published')
    model.reload
    expect(model.published).to be(true)
    expect(model.updated_by).to eq(user)

    accept_confirm do
      click_link('Hide')
    end
    expect(page).to have_content('Content hidden')
    model.reload
    expect(model.published).to be(false)
  end
end
