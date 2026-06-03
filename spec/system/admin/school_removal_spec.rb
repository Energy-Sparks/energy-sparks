require 'rails_helper'

RSpec.describe 'school removal', :schools, type: :system do
  let(:visible) { true }
  let(:school)  { create(:school, name: 'My High School', visible: visible) }

  let(:admin) { create(:admin) }

  before do
    sign_in(admin)
    visit school_path(school)
    click_on 'Remove school'
  end

  context 'if school still visible' do
    it 'shows message' do
      expect(page).to have_content('My High School')
      expect(page).to have_content('This school is still visible so cannot be deleted or archived.')
    end
  end

  context 'if school not visible' do
    let(:visible) { false }

    context 'and there are users' do
      let!(:school_admin)  { create(:school_admin, school: school) }

      before do
        refresh
        click_button 'Disable user accounts'
      end

      it 'removes the users' do
        expect(page).to have_content('Users have been disabled')
      end
    end

    context 'and there are meters' do
      let!(:electricity_meter) { create(:electricity_meter, school: school) }

      context 'when deactivating them' do
        before do
          refresh
          click_button 'Deactivate all meters and delete data'
        end

        it 'removes the meters' do
          expect(page).to have_content('Meters have been deactivated')
        end
      end

      context 'when archiving them' do
        before do
          refresh
          click_button 'Archive meters'
        end

        it 'removes the meters' do
          expect(page).to have_content('Meters have been archived')
        end
      end
    end

    context 'when the school is ready for removal' do
      it 'can be deleted' do
        click_button 'Delete school'
        expect(page).to have_content('School has been removed')
        expect(page).to have_content('This school was deleted')
      end

      it 'can be archived' do
        click_button 'Archive school'
        expect(page).to have_content('School has been archived')
        expect(page).to have_content('This school has been archived')
        expect(page).to have_content('Reenable school')
      end
    end

    context 'when a school has been removed' do
      let(:school)  { create(:school, name: 'My High School', visible: false, active: false, removal_date: Time.zone.today) }
      let!(:electricity_meter)  { create(:electricity_meter, school: school) }

      it 'is shown in the admin report' do
        visit admin_reports_path
        click_on 'Schools removed'
        expect(page).to have_content('My High School')
        expect(page).to have_content(Time.zone.today.to_fs(:es_full))
        expect(page).to have_link(electricity_meter.mpan_mprn.to_s)
      end

      it 'does not show status buttons' do
        visit school_path(school)
        expect(page).not_to have_css('#school-status-buttons')
      end
    end
  end
end
