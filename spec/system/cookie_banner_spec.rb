require 'rails_helper'

describe 'cookie banner' do
  def cookie_preference
    get_me_the_cookie('cookie_preference')
  end

  shared_examples 'a visible cookie banner' do
    it 'does not have cookie' do
      expect(cookie_preference).to be_nil
    end

    it 'includes expected content and links' do
      expect(page).to have_css('#cookie-banner')
      within('#cookie-banner') do
        expect(page).to have_content(I18n.t('cookie_banner.notice'))
        expect(page).to have_link(I18n.t('cookie_banner.learn_more'), href: cookies_path)
        expect(page).to have_button(I18n.t('cookie_banner.accept'))
        expect(page).to have_button(I18n.t('cookie_banner.reject'))
      end
    end

    context 'when following learn more link' do
      before do
        within('#cookie-banner') do
          click_on(I18n.t('cookie_banner.learn_more'))
        end
      end

      it 'displays the cookies page' do
        expect(page).to have_content(I18n.t('cookies.title'))
        expect(page).to have_content(I18n.t('cookies.essential.title'))
        expect(page).to have_content(I18n.t('cookies.essential.session.purpose'))
        expect(page).to have_content(I18n.t('cookies.essential.preference.purpose'))

        expect(page).to have_content(I18n.t('cookies.analytics.title'))
        expect(page).to have_content(I18n.t('cookies.analytics.ga.purpose'))
        expect(page).to have_content(I18n.t('cookies.analytics.gid.purpose'))
        expect(page).to have_content(I18n.t('cookies.analytics.question'))
        expect(page).to have_button(I18n.t('cookie_banner.accept'))
        expect(page).to have_button(I18n.t('cookie_banner.reject'))
      end
    end
  end

  shared_examples 'a preference has been set' do
    it 'hides banner' do
      expect(page).to have_css('#cookie-banner', visible: :hidden)
    end

    it 'sets cookie' do
      expect(cookie_preference[:value]).to eq(expected_preference)
      expect(cookie_preference[:expires].to_date).to eq(Time.zone.today + 1.year)
    end

    it 'does not show banner when page refreshed' do
      refresh
      expect(page).to have_css('#cookie-banner', visible: :hidden)
    end
  end

  shared_examples 'a dismissable cookie banner' do
    context 'when banner is accepted', :js do
      before do
        within('#cookie-banner') do
          click_on(I18n.t('cookie_banner.accept'))
        end
      end

      it_behaves_like 'a preference has been set' do
        let(:expected_preference) { 'Accepted' }
      end
    end

    context 'when banner is rejected', :js do
      before do
        within('#cookie-banner') do
          click_on(I18n.t('cookie_banner.reject'))
        end
      end

      it_behaves_like 'a preference has been set' do
        let(:expected_preference) { 'Rejected' }
      end
    end
  end

  context 'when no cookie has been set' do
    context 'when visiting pages that use the home layout' do
      before do
        visit root_path
      end

      it_behaves_like 'a visible cookie banner'
      it_behaves_like 'a dismissable cookie banner'
    end

    context 'when visiting pages that use the application layout' do
      before do
        visit schools_path
      end

      it_behaves_like 'a visible cookie banner'
      it_behaves_like 'a dismissable cookie banner'
    end
  end

  context 'when visiting the cookies page', :js do
    before do
      visit cookies_path
    end

    it 'displays the basic content' do
      expect(page).to have_content(I18n.t('cookies.title'))
      expect(page).to have_content(I18n.t('cookies.essential.title'))
      expect(page).to have_content(I18n.t('cookies.analytics.title'))
    end

    it 'displays both preference buttons when there is no existing preference' do
      within('#cookie-preference-buttons') do
        expect(page).to have_button(I18n.t('cookie_banner.accept'))
        expect(page).to have_button(I18n.t('cookie_banner.reject'))
      end
    end

    context 'when clicking accept button', :js do
      before do
        within('#cookie-preference-buttons') do
          click_on(I18n.t('cookie_banner.accept'))
        end
      end

      it 'updates page state correctly' do
        # accept button is hidden
        expect(page).to have_css('#cookie-preference-accept', visible: :hidden)
        # reject button is visible
        expect(page).to have_css('#cookie-preference-reject')

        # accepted message is visible
        expect(page).to have_css('#cookie-preference-accepted-message')
        # rejected message is hidden
        expect(page).to have_css('#cookie-preference-rejected-message', visible: :hidden)
      end

      it 'updates the cookie' do
        expect(cookie_preference[:value]).to eq('Accepted')
      end

      context 'when toggling the preference', :js do
        before do
          within('#cookie-preference-buttons') do
            click_on(I18n.t('cookie_banner.reject'))
          end
        end

        it 'updates page state correctly' do
          # reject button is hidden
          expect(page).to have_css('#cookie-preference-reject', visible: :hidden)
          # accept button is visible
          expect(page).to have_css('#cookie-preference-accept')

          # rejected message is visible
          expect(page).to have_css('#cookie-preference-rejected-message')
          # accepted message is hidden
          expect(page).to have_css('#cookie-preference-accepted-message', visible: :hidden)
        end

        it 'updates the cookie' do
          expect(cookie_preference[:value]).to eq('Rejected')
        end
      end

      it 'hides the cookie banner' do
        expect(page).to have_css('#cookie-banner', visible: :hidden)
      end
    end
  end
end
