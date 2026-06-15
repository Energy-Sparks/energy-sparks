require 'rails_helper'

RSpec.describe 'Robots', type: :system do
  it 'only disallows admin if crawling allowed' do
    ClimateControl.modify ALLOW_CRAWLING: 'true' do
      visit robots_path
      expect(page).to have_text('Disallow: /admin/')
      expect(page).to have_text('Sitemap')
    end
  end

  it 'disallows all' do
    visit robots_path
    expect(page).to have_text('Disallow: /')
    expect(page).to have_no_text('Disallow: /admin/')
  end
end
