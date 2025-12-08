# frozen_string_literal: true

# rubocop:disable RSpec/MultipleMemoizedHelpers

require 'rails_helper'

RSpec.describe 'school group status', :include_application_helper, :school_groups do
  around do |example|
    travel_to Date.new(2025, 9, 26)
    ClimateControl.modify AWESOMEPRINT: 'off' do
      example.run
    end
  end

  let!(:setup_data) {} # hook for dashboard messages - goes before page is loaded
  let!(:school_group) { create(:school_group, :with_grouping) }
  let(:statuses) { { visible: true, data_enabled: true } }
  let!(:onboarding) { }

  let!(:school) do
    create(:school,
          :with_basic_configuration_single_meter_and_tariffs,
          fuel_type: :electricity, **statuses,
          number_of_pupils: 20,
          floor_area: 300.0,
          school_group:)
  end
  let(:user) { create(:admin) }

  before do
    meter_collection = AggregateSchoolService.new(school).aggregate_school
    Schools::GenerateConfiguration.new(school, meter_collection).generate

    Flipper.enable :group_settings
    sign_in user
    visit school_group_status_index_path(school_group)
  end

  describe 'Dashboard message panel' do
    let(:messageable) { school_group }

    it_behaves_like 'admin dashboard messages'

    context 'when user is not a super admin (but still a group user)' do
      let(:user) { create(:group_admin, school_group:) }

      it_behaves_like 'a dashboard message'
    end
  end

  it 'has the title' do
    expect(page).to have_content("#{school_group.name} - #{I18n.t('school_groups.titles.school_status')}")
  end

  it_behaves_like 'a page always displaying the school group settings nav'

  context 'when there is a data visible school' do
    let(:statuses) { { visible: true, data_enabled: true } }

    it { expect(page).to have_link(school.name) }
    it { expect(page).to have_content('Data published') }
  end

  context 'when there is a visible school' do
    let(:statuses) { { visible: true, data_enabled: false } }

    it { expect(page).to have_link(school.name) }
    it { expect(page).to have_content('Visible') }
  end

  context 'when there is a school that is not visible or data visible' do
    let(:statuses) { { visible: false, data_enabled: false } }

    it { expect(page).to have_link(school.name) }
    it { expect(page).to have_content('Onboarding') }
  end

  context 'when there is an onboarding (with no school record)' do
    let(:onboarding) { create(:school_onboarding, school_group:) }

    it { expect(page).to have_content(onboarding.name) }
    it { expect(page).not_to have_link(onboarding.name) }
    it { expect(page).to have_content('Onboarding') }
  end

  context 'when there is an onboarding (with school record)' do
    let(:statuses) { { visible: false, data_enabled: false } }

    before do
      create(:school_onboarding, school:, school_group:)
      refresh
    end

    it { expect(page).to have_link(school.name) }
    it { expect(page).to have_content('Onboarding') }
  end

  context 'with downloads' do
    it { expect(page).to have_button(I18n.t('common.labels.download')) }

    context 'when clicking the botton', :js do
      before do
        click_button I18n.t('common.labels.download')
      end

      it 'has the schools download link' do
        expect(page).to have_link(I18n.t('school_groups.schools_as_csv'),
          href: school_group_status_index_path(school_group, format: :csv))
      end

      it 'has the meters download link' do
        expect(page).to have_link(I18n.t('school_groups.meters_as_csv'),
          href: meters_school_group_status_index_path(school_group, format: :csv)
        )
      end
    end

    context 'when clicking the schools download link' do
      before do
        click_on I18n.t('school_groups.schools_as_csv')
      end

      it { expect(page).to have_content(school.floor_area) } # further tests available in service
    end

    context 'when clicking the meters download link' do
      before do
        click_on I18n.t('school_groups.meters_as_csv')
      end

      it { expect(page).to have_content(school.meters.first.mpan_mprn) } # further tests available in service
    end
  end

  context 'when visiting the school specific page' do
    before do
      create(:school_onboarding, :with_events, school:, school_group:, event_names: [:onboarding_complete, :onboarding_data_enabled])
      create(:contact_with_name_email_phone, school:, user: create(:school_admin, school:)) # user receiving alerts

      click_on school.name
    end

    context 'with school information' do
      it { expect(page).to have_content(school.floor_area) }
      it { expect(page).to have_content(school.full_location_to_s) }
      it { expect(page).to have_content(school.number_of_pupils) }
      it { expect(page).to have_content(I18n.t("common.school_types.#{school.school_type}"))}
      it { expect(page).to have_content("Number of users #{school.active_adult_users.count} (1 receiving alerts)")}
    end

    context 'with key dates' do
      it { expect(page).to have_content(nice_dates(school.school_onboarding.completed_on)) }
      it { expect(page).to have_content(nice_dates(school.school_onboarding&.first_made_data_enabled)) }
    end

    context 'with energy data' do
      it { expect(page).to have_content('Energy data') }
      it { expect(page).to have_selector('.schools-energy-data-status-component') }
    end

    context 'with meter data' do
      it { expect(page).to have_content('Individual meter data') }
      it { expect(page).to have_selector('.schools-meter-status-component') }

      it 'has the meters download link' do
        expect(page).to have_link(I18n.t('school_groups.download_as_csv'),
          href: school_school_group_status_index_path(school_group, school, format: :csv)
        )
      end

      context 'when clicking the meters download link' do
        before do
          click_on I18n.t('school_groups.download_as_csv')
        end

        it { expect(page).to have_content(school.meters.first.mpan_mprn) } # further tests available in service
      end
    end
  end

  context 'when group is a project group' do
    let(:school_group) { create(:school_group, :with_grouping, role: :project, group_type: :project) }
    let(:school) do
      create(:school,
          :with_basic_configuration_single_meter_and_tariffs,
          fuel_type: :electricity, **statuses,
          project_groups: [school_group])
    end

    before do
      click_on school.name
    end

    it { expect(page).to have_http_status(:ok) }
    it { expect(page).to have_content(school.name) }
  end
end

# rubocop:enable RSpec/MultipleMemoizedHelpers
