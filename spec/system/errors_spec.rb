require 'rails_helper'

RSpec.describe 'errors', type: :system do
  describe '404' do
    before do
      visit '/404'
    end

    it { expect(page.status_code).to be 404 }
    it { expect(page).to have_content '404' }
    it { expect(page).to have_content 'Page not found' }
    it { expect(page).to have_content 'Sorry, the page you are looking for does not exist' }
    it { expect(page).to have_content 'Please continue to our home page.' }
  end

  describe '500' do
    before do
      visit '/500'
    end

    it { expect(page.status_code).to be 500 }
    it { expect(page).to have_content '500' }
    it { expect(page).to have_content 'Sorry, something has gone wrong' }
    it { expect(page).to have_content 'The Energy Sparks team have been notified' }
    it { expect(page).to have_content 'Please continue to our home page.' }
  end

  describe '422' do
    before do
      visit '/422'
    end

    it { expect(page.status_code).to be 422 }
    it { expect(page).to have_content '422' }
    it { expect(page).to have_content 'The change you wanted was rejected' }
    it { expect(page).to have_content "Maybe you tried to change something you didn't have access to." }
    it { expect(page).to have_content 'Please continue to our home page.' }
  end
end