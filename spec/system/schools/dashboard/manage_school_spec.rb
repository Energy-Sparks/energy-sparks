require 'rails_helper'

RSpec.describe 'manage school', type: :system do
  let(:school) { create(:school, :with_school_group) }
  let!(:fuel_configuration) { Schools::FuelConfiguration.new(has_electricity: true, has_gas: true, has_storage_heaters: true)}

  before do
    # Update the configuration rather than creating one, as the school factory builds one
    # and so if we call create(:configuration, school: school) we end up with 2 records for the has_one
    # relationship
    school.configuration.update!(fuel_configuration: fuel_configuration)

    sign_in(user) if user.present?
  end

  context 'as guest' do
    let(:user) { nil }

    it 'does not have a manage menu' do
      visit school_path(school)
      expect(page).not_to have_css('#manage_school')
    end
  end

  context 'as pupil' do
    let(:user) { create(:pupil, school: school) }

    it 'does not have my school menu' do
      visit school_path(school, switch: true)
      expect(page).not_to have_css('#manage_school')
    end
  end

  context 'as staff' do
    let(:user) { create(:staff, school: school) }

    before do
      visit school_path(school)
    end

    it 'does not have a manage menu' do
      expect(page).not_to have_css('#manage_school')
    end
  end

  shared_examples 'a manage school menu' do
    it 'has manage school menu' do
      expect(page).to have_css('#manage_school')
      within '#manage_school_menu' do
        expect(page).to have_link('Edit school details')
        expect(page).to have_link('Edit school times')
        expect(page).to have_link('School calendar')
        expect(page).to have_link('Manage users')
        expect(page).to have_link('Manage alert contacts')
        expect(page).to have_link('Manage meters')
        expect(page).to have_link('Digital signage')
      end
    end
  end

  shared_examples 'a manage school menu displaying admin section' do
    it 'shows extra manage menu items' do
      expect(page).to have_css('#manage_school')
      within '#manage_school_menu' do
        expect(page).to have_link('Review school setup')
        expect(page).to have_link('School configuration')
        expect(page).to have_link('Meter attributes')
        expect(page).to have_link('Manage school group')
        expect(page).to have_link('Manage issues')
        expect(page).to have_link('Batch reports')
        expect(page).to have_link('Expert analysis')
        expect(page).to have_link('Remove school')
        expect(page).to have_link(I18n.t('components.manage_school_navigation.settings'))
      end
    end
  end

  shared_examples 'a manage school menu not displaying admin section' do
    it 'does not shows extra manage menu items' do
      expect(page).to have_css('#manage_school')
      within '#manage_school_menu' do
        expect(page).not_to have_link('Review school setup')
        expect(page).not_to have_link('School configuration')
        expect(page).not_to have_link('Meter attributes')
        expect(page).not_to have_link('Manage school group')
        expect(page).not_to have_link('Manage issues')
        expect(page).not_to have_link('Batch reports')
        expect(page).not_to have_link('Expert analysis')
        expect(page).not_to have_link('Remove school')
        expect(page).to have_link(I18n.t('components.manage_school_navigation.settings'))
      end
    end
  end

  context 'as school admin' do
    let(:user) { create(:school_admin, school: school) }

    before { visit school_path(school) }

    it_behaves_like 'a manage school menu'
    it_behaves_like 'a manage school menu not displaying admin section'
  end

  context 'as group admin' do
    let(:school_group)  { create(:school_group) }
    let(:school)        { create(:school, school_group: school_group) }
    let(:user)          { create(:group_admin, school_group: school_group) }

    before { visit school_path(school) }

    it_behaves_like 'a manage school menu'
    it_behaves_like 'a manage school menu not displaying admin section'
  end

  context 'as admin' do
    let(:user) { create(:admin) }

    before { visit school_path(school) }

    it_behaves_like 'a manage school menu'
    it_behaves_like 'a manage school menu displaying admin section'

    it 'displays batch reports' do
      visit school_path(school)
      click_on 'Batch reports'
      expect(page).to have_link('Content reports')
      expect(page).to have_link('Alert reports')
      expect(page).to have_link('Email and SMS reports')
    end

    context 'with status toggles', with_feature: :new_manage_school_pages do
      it 'links to the configuration page for data access settings' do
        visit school_path(school)
        click_on('Public')
        expect(page).to have_select('Data Sharing', selected: 'Public')
        select 'Within Group', from: 'Data Sharing'
        click_on 'Update configuration'

        within '#data-sharing-status' do
          expect(page).to have_content('Within Group')
        end

        school.reload
        expect(school.data_sharing_within_group?).to be true
      end

      it 'allows toggling visibility' do
        visit school_path(school)
        click_on('Visible')
        school.reload
        expect(school).not_to be_visible
        click_on('Visible')
        school.reload
        expect(school).to be_visible
      end

      it 'allows toggling of data processing' do
        create(:gas_meter, :with_unvalidated_readings, school: school)
        school.update(process_data: false)
        visit school_path(school)
        expect(page).not_to have_link(href: school_batch_runs_path(school))
        click_on('Process data')
        expect(page).to have_content "#{school.name} will now process data"
        expect(page).to have_link(href: school_batch_runs_path(school))
        school.reload
        expect(school.process_data).to eq(true)
        click_on('Process data')
        school.reload
        expect(school.process_data).to eq(false)
      end

      it 'disallows toggling of data processing if the school has no meter readings' do
        school.update(process_data: false)
        visit school_path(school)
        click_on('Process data')
        expect(page).to have_content "#{school.name} cannot process data as it has no meter readings"
        school.reload
        expect(school.process_data).to eq(false)
      end

      it 'allows toggling of data enabled via the review page' do
        create(:consent_grant, school: school)
        visit school_path(school)
        click_on('Data visible')
        school.reload
        expect(school).not_to be_data_enabled
        click_on('Data visible')

        school.reload
        expect(school).not_to be_data_enabled

        expect(page).to have_content('School setup review')
        within('#review-buttons') do
          click_on 'Data visible' # actually enable the school
        end

        school.reload
        expect(school).to be_data_enabled
      end
    end
  end
end
