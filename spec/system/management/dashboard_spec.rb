require 'rails_helper'

describe 'Adult dashboard' do

  let(:school_name)         { 'Theresa Green Infants'}
  let!(:school_group)       { create(:school_group) }
  let!(:regional_calendar)  { create(:regional_calendar) }
  let!(:calendar)           { create(:school_calendar, based_on: regional_calendar) }
  let!(:school)             { create(:school, :with_feed_areas, calendar: calendar, name: school_name, school_group: school_group) }
  let!(:intervention)       { create(:observation, school: school) }

  let!(:school_admin)       { create(:school_admin, school: school)}
  let(:staff)               { create(:staff, school: school, staff_role: create(:staff_role, :management)) }

  describe 'when not logged in' do
    it 'prompts for login' do
      visit management_school_path(school)
      expect(page).to have_content("Sign in to Energy Sparks")
    end
  end

  context 'when logged in as pupil' do
    let(:pupil) { create(:pupil, school: school)}
    before(:each) do
      sign_in(pupil)
    end
    it 'allows login and access to dashboard' do
      visit root_path
      expect(page).to have_content("#{school.name}")
      expect(page).to have_link("Adult dashboard", href: management_school_path(school))
      click_on 'Adult dashboard'
      expect(page).to have_content("#{school.name}")
      expect(page).to have_link("Compare schools")
    end
  end

  context 'when logged in as staff' do
    before(:each) do
      sign_in(staff)
    end

    it 'allows login and access to dashboard' do
      visit root_path
      expect(page).to have_content("#{school.name}")
      expect(page).to have_content("Adult Dashboard")
      expect(page).to have_content("Recorded temperatures")
      expect(page).to have_link("Compare schools")
    end

    describe 'with management priorities' do

      let!(:gas_fuel_alert_type) { create(:alert_type, fuel_type: :gas, frequency: :weekly) }
      let!(:alert_type_rating) do
        create(
          :alert_type_rating,
          alert_type: gas_fuel_alert_type,
          rating_from: 0,
          rating_to: 10,
          management_priorities_active: true,
        )
      end
      let!(:alert_type_rating_content_version) do
        create(
          :alert_type_rating_content_version,
          alert_type_rating: alert_type_rating,
          management_priorities_title: 'Spending too much money on heating',
        )
      end
      let(:alert_summary){ 'Summary of the alert' }
      let!(:alert) do
        create(:alert, :with_run,
          alert_type: gas_fuel_alert_type,
          run_on: Date.today, school: school,
          rating: 9.0,
          template_data: {
            average_capital_cost: '£2,000'
          }
        )
      end

      before do
        Alerts::GenerateContent.new(school).perform
      end

      it 'displays the priorities in a table' do
        visit root_path
        expect(page).to have_content('Spending too much money on heating')
        expect(page).to have_content('£2,000')
      end

      it 'displays energy saving target prompt' do

        allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(true)
        allow_any_instance_of(::Targets::SchoolTargetService).to receive(:enough_data?).and_return(true)

        visit root_path
        expect(page).to have_content("Set targets to reduce your school's energy consumption")
        expect(page).to have_link('Set energy saving target')

        school.school_targets << create(:school_target)
        visit root_path
        expect(page).not_to have_content("Set targets to reduce your school's energy consumption")
      end

      it 'doesnt displays energy saving target prompt if not enough data' do
        allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(true)
        allow_any_instance_of(::Targets::SchoolTargetService).to receive(:enough_data?).and_return(false)

        visit root_path
        expect(page).to_not have_content("Set targets to reduce your school's energy consumption")
      end

      it 'doesnt display prompt if feature disabled for school' do
        allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(true)
        school.update!(enable_targets_feature: false)
        visit root_path
        expect(page).to_not have_content("Set targets to reduce your school's energy consumption")
      end

      it 'displays a report version of the page' do
        visit root_path
        click_on 'Print view'
        expect(page).to have_content("Management information for #{school.name}")
        expect(page).to have_content('Spending too much money on heating')
        expect(page).to have_content('£2,000')
      end
    end

    describe 'with targets' do
      let(:progress_summary) { nil }
      let!(:school_target)    { create(:school_target, school: school) }

      before(:each) do
        allow_any_instance_of(Targets::ProgressService).to receive(:progress_summary).and_return(progress_summary)
        visit school_path(school)
      end

      context 'and there is no data' do
        it 'has no notice' do
          expect(page).to_not have_content("you are currently meeting all of your energy saving targets")
          expect(page).to_not have_content("Unfortunately you are not meeting your targets")
        end
      end

      context 'that are being met' do
        let(:progress_summary)  { build(:progress_summary, school_target: school_target) }
        it 'displays a notice' do
          expect(page).to have_content("you are currently meeting all of your energy saving targets")
        end

        it 'links to target page' do
          expect(page).to have_link("Review progress", href: school_school_targets_path(school))
        end
      end

      context 'that are not being met' do
        let(:progress_summary)  { build(:progress_summary_with_failed_target, school_target: school_target) }

        it 'displays a notice' do
          expect(page).to have_content("Unfortunately you are not meeting your target to reduce your gas usage")
        end

        it 'links to target page' do
          expect(page).to have_link("Review progress", href: school_school_targets_path(school))
        end
      end
    end
  end

  context 'when logged in as a school admin' do
    before(:each) do
      sign_in(school_admin)
    end

    it 'I can visit the dashboard' do
      visit management_school_path(school)
      expect(page).to have_content(school_name)
      expect(page).to have_link("Compare schools")
    end

    it 'shows link to co2 analysis page' do
      co2_page = double(analysis_title: 'Some CO2 page', analysis_page: 'analysis/page/co2')
      expect_any_instance_of(Management::SchoolsController).to receive(:process_analysis_templates).and_return([co2_page])
      visit management_school_path(school)
      expect(page).to have_link("Some CO2 page")
    end

    it 'displays interventions and temperature recordings in a timeline' do
      intervention_type = create(:intervention_type, title: 'Upgraded insulation')
      create(:observation, :intervention, school: school, intervention_type: intervention_type)
      create(:observation_with_temperature_recording_and_location, school: school)
      activity_type = create(:activity_type) # doesn't get saved if built with activity below
      create(:activity, school: school, activity_type: activity_type)

      visit management_school_path(school)
      expect(page).to have_content('Recorded temperatures in')
      expect(page).to have_content('Upgraded insulation')
      expect(page).to have_content('Completed an activity')
      click_on 'View all actions'
      expect(page).to have_content('Recorded temperatures in')
      expect(page).to have_content('Upgraded insulation')
      expect(page).to have_content('Completed an activity')
    end

    describe 'has a loading page which redirects to the right place', js: true do
      before(:each) do
        allow(AggregateSchoolService).to receive(:caching_off?).and_return(false, true)
        allow_any_instance_of(AggregateSchoolService).to receive(:aggregate_school).and_return(school)
        allow_any_instance_of(ChartData).to receive(:data).and_return(nil)
      end

      context 'with a successful load' do
        before(:each) do
          allow_any_instance_of(AggregateSchoolService).to receive(:aggregate_school).and_return(school)
          school.configuration.update(gas_dashboard_chart_type: Schools::Configuration::TEACHERS_GAS_SIMPLE)
        end
        it 'renders a loading page and then back to the dashboard page once complete' do
          visit management_school_path(school)

          expect(page).to have_content('Your annual usage')
          # if redirect fails it will still be processing
          expect(page).to_not have_content('processing')
          expect(page).to_not have_content("we're having trouble processing your energy data today")
        end
      end

      context 'with a loading error' do
        before(:each) do
          allow_any_instance_of(AggregateSchoolService).to receive(:aggregate_school).and_raise(StandardError, 'It went wrong')
        end

        it 'shows an error message', errors_expected: true do
          visit management_school_path(school)
          expect(page).to have_content("we're having trouble processing your energy data today")
        end
      end
    end

  end

end
