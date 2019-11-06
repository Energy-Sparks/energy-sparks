require 'rails_helper'

RSpec.describe "Robots", type: :system do
  it 'only disallows admin if crawling allowed' do
    ClimateControl.modify ALLOW_CRAWLING: 'true' do
      visit robots_path
      expect(page).to have_content('Disallow: /admin/')
      expect(page).to have_content('Sitemap')
    end
  end

  it 'disallows all' do
    visit robots_path
    expect(page).to have_content('Disallow: /')
    expect(page).to_not have_content('Disallow: /admin/')
  end
end
