require 'rails_helper'

describe 'School Alert Type Exclusions', :include_application_helper do
  let!(:school) { create(:school) }
  let!(:alert_type) { create_list(:alert_type, 2) }
  let(:user) { create(:admin) }

  context 'when not logged in' do
    before do
      visit school_school_alert_type_exclusions_path(school)
    end

    it_behaves_like 'the page requires a login'
  end

  context 'when logged in as school admin' do
    let(:user) { create(:school_admin, school: school) }

    before do
      sign_in(user)
      visit school_school_alert_type_exclusions_path(school)
    end

    it_behaves_like 'the user is not authorised'
  end

  context 'when logged in as admin' do
    let(:exclusion) { nil }

    before do
      sign_in(user)
      exclusion
      visit school_school_alert_type_exclusions_path(school)
    end

    context 'with no exclusions' do
      it { expect(page).to have_content('School does not have any exclusions') }
    end

    context 'with exclusions' do
      let(:exclusion) { create(:school_alert_type_exclusion, school: school) }

      it 'displays detail' do
        within('#exclusions') do
          expect(page).to have_content(exclusion.alert_type.title)
          expect(page).to have_content(exclusion.reason)
          expect(page).to have_content(exclusion.created_by.name)
        end
      end

      context 'when deleting', :js do
        before do
          within('#exclusions') do
            accept_confirm do
              click_on('Delete')
            end
          end
        end

        it 'deletes the exclusion' do
          expect(page).to have_content('Exclusion deleted')
          expect(page).to have_content('School does not have any exclusions')
        end
      end
    end

    context 'when adding an exclusion' do
      before do
        fill_in 'Reason', with: 'This is my reason'
        click_on 'Add Exclusion'
      end

      it 'allows exclusion to be created' do
        expect(page).to have_content('Exclusion created')
        within('#exclusions') do
          expect(page).to have_content('This is my reason')
          expect(page).to have_content(user.name)
        end
      end
    end
  end
end
