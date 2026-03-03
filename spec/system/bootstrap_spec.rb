require 'rails_helper'

RSpec.describe 'Bootstrap switcher', type: :system do
  shared_examples 'a bootstrap 4 page' do
    it { expect(page).to have_css('.bs4') }
    it { expect(page).to have_text('Bootstrap 4') }
    it { expect(page).to have_link('switch to 5') }
    it { expect(page).to have_css('.badge.text-bg-danger') }
  end

  shared_examples 'a bootstrap 5 page' do
    it { expect(page).to have_css('.bs5') }
    it { expect(page).to have_text('Bootstrap 5') }
    it { expect(page).to have_link('switch to 4') }
    it { expect(page).to have_css('.badge.text-bg-success') }
  end

  context with_feature: :bootstrap_switcher do
    context 'when bs5 param is not set' do
      before { visit root_path }

      it_behaves_like 'a bootstrap 4 page'
    end

    context 'when bs5 param is set to false' do
      before { visit root_path(bs5: 'false') }

      it_behaves_like 'a bootstrap 4 page'
    end

    context 'when bs5 param is set to true' do
      before { visit root_path(bs5: 'true') }

      it_behaves_like 'a bootstrap 5 page'
    end

    context 'when clicking the switch link' do
      before do
        visit root_path
        click_link 'switch to 5'
      end

      it_behaves_like 'a bootstrap 5 page'
      context 'when switching back to 4' do
        before { click_link 'switch to 4' }

        it_behaves_like 'a bootstrap 4 page'
      end
    end

    context 'when visiting a page already switched to bs5' do
      before do
        login_as(create(:admin))
        visit admin_styles_path
      end

      it_behaves_like 'a bootstrap 5 page'

      context 'when switching back to bs4' do
        before { click_link 'switch to 4' }

        it_behaves_like 'a bootstrap 4 page'
      end
    end
  end

  context without_feature: :bootstrap_switcher do
    context 'when visiting the root path' do
      before { visit root_path }

      it 'does not show the switcher' do
        expect(page).not_to have_text('Bootstrap')
      end

      context 'when bs5 param is set to true' do
        before { visit root_path(bs5: 'true') }

        it { expect(page).not_to have_css('.bs5') }
        it { expect(page).to have_css('.bs4') }
      end
    end

    context 'when visiting a page already switched to bs5' do
      before do
        login_as(create(:admin))
        visit admin_styles_path
      end

      it { expect(page).to have_css('.bs5') }
      it { expect(page).not_to have_css('.bs4') }
    end
  end
end
