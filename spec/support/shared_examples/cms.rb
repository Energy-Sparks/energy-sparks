RSpec.shared_examples_for 'a cms admin page' do
  it 'has links to all index pages' do
    expect(page).to have_link('Categories', href: admin_cms_categories_path)
    expect(page).to have_link('Pages', href: admin_cms_pages_path)
    expect(page).to have_link('Sections', href: admin_cms_sections_path)
  end
end

RSpec.shared_examples_for 'a cms page header' do
  it 'displays title and description' do
    within('.layout-cards-page-header-component') do
      expect(page).to have_content(model.title)
      expect(page).to have_content(model.description)
    end
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

RSpec.shared_examples_for 'a page with a support page nav' do
  let(:categories) { Cms::Category.all.published }
  let(:pages) { Cms::Page.all.published }
  let(:current_category) { nil }

  it 'displays all categories as collapsable sections' do
    within('#page-nav') do
      categories.each do |category|
        if current_category == category
          expect(page).to have_css("a.nav-link[data-target='##{category.slug}']")
        else
          expect(page).to have_css("a.nav-link.collapsed[data-target='##{category.slug}']")
        end
      end
    end
  end

  it 'links to all pages within their category' do
    within('#page-nav') do
      pages.each do |cms_page|
        within("div##{cms_page.category.slug}") do
          expect(page).to have_link(cms_page.title, href: category_page_path(cms_page.category, cms_page))
        end
      end
    end
  end
end
