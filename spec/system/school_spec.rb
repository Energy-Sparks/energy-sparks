require 'rails_helper'

RSpec.describe "school adult dashboard", type: :system do

  let(:school_name)         { 'Oldfield Park Infants' }

  let!(:school_group)       { create(:school_group, name: 'School Group')}

  let!(:regional_calendar)  { create(:regional_calendar) }
  let!(:calendar)           { create(:school_calendar, based_on: regional_calendar) }

  let!(:school)             { create(:school, calendar: calendar, name: school_name, latitude: 51.34062, longitude: -2.30142)}

  let!(:fuel_configuration) { Schools::FuelConfiguration.new(has_electricity: true, has_gas: true, has_storage_heaters: true)}

  let(:management_data) {
    Tables::SummaryTableData.new({ electricity: { year: { :percent_change => 0.11050 }, workweek: { :percent_change => -0.0923132131 } } })
  }

  before(:each) do
    allow_any_instance_of(Schools::ManagementTableService).to receive(:management_data).and_return(management_data)

    #Update the configuration rather than creating one, as the school factory builds one
    #and so if we call create(:configuration, school: school) we end up with 2 records for a has_one
    #relationship
    school.configuration.update!(fuel_configuration: fuel_configuration)
  end

  context 'as a guest user' do

    it 'shows me the adult dashboard by default' do
      visit root_path
      click_on('View schools')
      expect(page.has_content? "Energy Sparks schools across the UK").to be true
      click_on(school_name)

      expect(page.has_link? "Pupil dashboard").to be true
      expect(page.has_content? school_name).to be true
    end

    it 'shows login form' do
      visit school_path(school)
      expect(page).to have_content('Log in with your email address and password')
      expect(page).to have_content('Log in with your pupil password')
    end

    it 'shows data-enabled features' do
      visit school_path(school)
      expect(page).to have_content("Summary of recent energy usage")
    end

    it 'shows data-enabled links' do
      visit school_path(school)
      expect(page).to have_link("Explore data")
      expect(page).to have_link("Review energy analysis")
    end

    it 'links to the pupil dashboard' do
      visit school_path(school)
      within('.sub-navbar') do
        click_on('Pupil dashboard')
      end
      expect(page.has_title? 'Pupil dashboard').to be true
      expect(page.has_link? "Adult dashboard").to be true
      expect(page.has_content? school_name).to be true
    end

    describe 'has a loading page which redirects to the right place' do
      before(:each) do
        allow(AggregateSchoolService).to receive(:caching_off?).and_return(false, true)
        allow_any_instance_of(AggregateSchoolService).to receive(:aggregate_school).and_return(school)
      end

      #non-javascript version of test to check that right template is delivered
      context 'displays the holding page template' do
        it 'renders a loading page' do
          visit school_path(school)
          expect(page).to have_content("Energy Sparks is processing all of this school's data to provide today's analysis")
        end
      end

      context 'with a successful ajax load', js: true do
        it 'renders a loading page and then back to the dashboard page on success' do
          visit school_path(school)

          expect(page).to have_content('Adult Dashboard')
          # if redirect fails it will still be processing
          expect(page).to_not have_content('processing')
          expect(page).to_not have_content("we're having trouble processing your energy data today")
        end
      end

      context 'with an ajax loading error', js: true do
        before(:each) do
          allow_any_instance_of(AggregateSchoolService).to receive(:aggregate_school).and_raise(StandardError, 'It went wrong')
        end

        it 'shows an error message', errors_expected: true do
          visit school_path(school)
          expect(page).to have_content("we're having trouble processing your energy data today")
        end
      end
    end


    context 'with school in group' do
      let(:public)      { true }

      before(:each) do
        school.update(school_group: create(:school_group, public: public))
      end

      it 'links to compare schools in public groups' do
        visit school_path(school)
        expect(page).to have_link("Compare schools")
      end

      context 'and group is private' do
        let(:public)      { false }

        it 'doesnt link to compare schools' do
          visit school_path(school)
          within('.application') do
            expect(page).to_not have_link("Compare schools")
          end
        end

        context 'and signed in as school user' do
          let!(:school_admin)          { create(:school_admin, school: school) }
          before(:each) do
            sign_in(school_admin)
          end
          it 'links to compare schools' do
            visit school_path(school)
            within('.application') do
              expect(page).to have_link("Compare schools")
            end
          end
        end
      end
    end

    context 'when school has partners' do

      let(:partner)             { create(:partner, name: "School Sponsor", url: "http://example.org") }
      let(:other_partner)       { create(:partner, name: "Big Tech Co", url: "https://example.com") }

      before(:each) do
        school.update!( {school_group: school_group })
      end

      it 'displays school group partners' do
        school.school_group.partners << partner
        visit school_path(school)
        expect(page).to have_link("School Sponsor", href: "http://example.org")
      end

      it 'displays school partners' do
        school.partners << partner
        visit school_path(school)
        expect(page).to have_link("School Sponsor", href: "http://example.org")
      end

      it 'displays all partners' do
        school.school_group.partners << partner
        school.partners << other_partner
        visit school_path(school)
        expect(page).to have_link("School Sponsor", href: "http://example.org")
        expect(page).to have_link("Big Tech Co", href: "https://example.com")
      end

    end

  end

  context 'with invisible school' do
    let!(:school_invisible)       { create(:school, name: 'Invisible School', visible: false, school_group: school_group)}

    context "as guest user" do
      it 'does not show invisible school or the group' do
        visit root_path
        click_on('View schools')
        expect(page.has_content? school_name).to be true
        expect(page.has_content? 'Invisible School').to_not be true
        expect(page.has_content? 'School Group').to_not be true
      end

      it 'prompts user to login when viewing' do
        visit school_path(school_invisible)
        expect(page.has_content? 'You are not authorized to access this page').to be true
      end

      context 'when also not data enabled' do
        it 'does not raise a double render error' do
          school_invisible.update(data_enabled: false)
          visit school_path(school_invisible)
          expect(page.has_content? 'You are not authorized to access this page').to be true
        end
      end
    end

    context 'as admin' do
      let!(:admin)              { create(:admin)}

      before(:each) do
        sign_in(admin)
        visit root_path
        click_on('View schools')
      end

      it 'does show invisible school, but not the group' do
        expect(page.has_content? school_name).to be true
        expect(page.has_content? 'Not visible schools').to be true
        expect(page.has_content? 'Invisible School').to be true
        expect(page.has_content? 'School Group').to_not be true
      end

      it 'shows school' do
        visit school_path(school_invisible)
        expect(page.has_link? "Pupil dashboard").to be true
        expect(page.has_content? school_invisible.name).to be true
      end

    end

  end

  context 'non-public school' do
    let!(:non_public_school)       { create(:school, name: 'Non-public School', visible: true, public: false, school_group: school_group)}

    context 'as unknown user' do

      it 'is listed on school page' do
        visit root_path
        click_on('View schools')

        expect(page.has_content? non_public_school.name).to be true
        expect(page.has_content? 'School Group').to be true
      end

      it 'prompts user to login when viewing' do
        visit school_path(non_public_school)
        expect(page.has_content? 'This school has disabled public access').to be true
      end
    end

    context 'as staff' do
      let!(:school_admin)          { create(:school_admin, school: non_public_school) }

      before(:each) do
        sign_in(school_admin)
      end

      it 'displays the school page' do
        visit school_path(non_public_school)
        expect(page).to have_content(non_public_school.name)
        expect(page).to have_link("Compare schools")
      end

      it 'redirects away user from the /private page' do
        visit school_private_path(non_public_school)
        expect(page).to have_content(non_public_school.name)
        expect(page).to have_link("Compare schools")
      end

    end

    context 'as a user in the same school group' do
      let!(:school_in_same_group)   { create(:school, name: 'Same Group School', visible: true, school_group: school_group)}
      let!(:other_admin)            { create(:school_admin, school: school_in_same_group) }

      before(:each) do
        sign_in(other_admin)
      end

      it 'displays the school page' do
        visit school_path(non_public_school)
        expect(page).to have_content(non_public_school.name)
        expect(page).to have_link("Compare schools")
      end

    end

    context 'as a unrelated school user' do
      let!(:other_admin)    { create(:school_admin) }
      before(:each) do
        sign_in(other_admin)
      end

      it 'prompts user to login when viewing' do
        visit school_path(non_public_school)
        expect(page.has_content? 'This school has disabled public access').to be true
      end

    end

  end

  context 'as an admin' do
    let!(:admin)              { create(:admin)}

    before(:each) do
      sign_in(admin)
      visit root_path
      expect(page.has_content? 'Sign Out').to be true
      click_on('View schools')
      expect(page.has_content? "Energy Sparks schools across the UK").to be true
    end

    describe 'managing a school' do
      let!(:ks1)                { KeyStage.create(name: 'KS1') }
      let!(:ks2)                { KeyStage.create(name: 'KS2') }
      let!(:ks3)                { KeyStage.create(name: 'KS3') }

      context 'and updating the school configuration' do

        it 'I can set up a school for KS1' do
          click_on(school_name)
          click_on('Edit school details')
          expect(school.key_stages).to_not include(ks1)
          expect(school.key_stages).to_not include(ks2)
          expect(school.key_stages).to_not include(ks3)

          check('KS1')
          click_on('Update School')
          school.reload
          expect(school.key_stages).to include(ks1)
          expect(school.key_stages).to_not include(ks2)
          expect(school.key_stages).to_not include(ks3)
        end

        it 'I can set up a school for KS1 and KS2' do
          click_on(school_name)
          click_on('Edit school details')
          expect(school.key_stages).to_not include(ks1)
          expect(school.key_stages).to_not include(ks2)
          expect(school.key_stages).to_not include(ks3)

          check('KS1')
          check('KS2')
          click_on('Update School')
          school.reload
          expect(school.key_stages).to include(ks1)
          expect(school.key_stages).to include(ks2)
          expect(school.key_stages).to_not include(ks3)
        end

        it 'can set climate impact reporting preference' do
          click_on(school_name)
          click_on('Edit school details')

          choose('Prefer the display of chart data in kg CO2, where available')
          click_on('Update School')
          school.reload

          expect(school.chart_preference).to eq "carbon"
        end

        it 'can see when the school was created on Energy Sparks' do
          click_on(school_name)
          click_on('Edit school details')
          date = school.created_at
          expect(page).to have_content "#{school.name} was created on #{date.strftime('%a')} #{date.day.ordinalize} #{date.strftime('%b %Y')}"
        end

        it 'can edit lat/lng' do
          click_on(school_name)
          click_on('Edit school details')

          fill_in 'Latitude', with: '52.123'
          fill_in 'Longitude', with: '-1.123'
          click_on('Update School')

          school.reload
          expect(school.latitude.to_s).to eq('52.123')
          expect(school.longitude.to_s).to eq('-1.123')
        end

        it 'can create an active date' do
          click_on(school_name)
          click_on('Edit school details')

          expect(school.observations).to be_empty

          expect(page).to have_field('Activation date')
          activation_date = Date.parse('01/01/2020')

          fill_in 'Activation date', with: activation_date.strftime("%d/%m/%Y")
          click_on('Update School')

          expect(school.observations.first.description.to_s).to include("became an active user of Energy Sparks!")

          school.reload
          expect(school.activation_date).to eq activation_date

          click_on('Edit school details')
          fill_in 'Activation date', with: ''
          click_on('Update School')

          school.reload
          expect(school.activation_date).to eq nil
        end

        it 'can change target feature flag' do
          expect(school.enable_targets_feature?).to be true
          click_on(school_name)
          click_on('Edit school details')
          uncheck 'Enable targets feature'
          click_on('Update School')
          school.reload
          expect(school.enable_targets_feature?).to be false
        end

        context "can update storage heaters" do
          it "and changes are saved" do
            click_on(school_name)
            click_on('Edit school details')
            check 'Our school has night storage heaters'

            click_on('Update School')

            school.reload
            expect(school.indicated_has_storage_heaters).to be true
          end
        end

        it 'can change climate reporting preference' do
          school.update!(chart_preference: :usage)
          click_on(school_name)
          click_on('Edit school details')
          choose('Prefer the display of chart data in £, where available')
          click_on('Update School')

          school.reload
          expect(school.chart_preference).to eq "cost"
        end

      end

      it 'allows public/non-public management from school page' do
        click_on(school_name)
        click_on('Public')
        school.reload
        expect(school).to_not be_public
        click_on('Public')
        school.reload
        expect(school).to be_public
      end

      it 'allows visibility management from school page' do
        create :consent_grant, school: school
        click_on(school_name)
        click_on('Visible')
        school.reload
        expect(school).to_not be_visible
        click_on('Visible')
        school.reload
        expect(school).to be_visible
      end

      it 'disallows visibility change if school doesnt have consent' do
        expect(school.consent_up_to_date?).to be false
        click_on(school_name)
        click_on('Visible')
        school.reload
        expect(school).to_not be_visible
        click_on('Visible')
        expect(page).to have_content("School cannot be made visible as we dont have a record of consent")
        school.reload
        expect(school).to_not be_visible
      end

      it 'allows data process management' do
        create(:gas_meter, :with_unvalidated_readings, school: school)
        school.update(process_data: false)
        click_on(school_name)
        click_on('Process data')
        expect(page).to have_content "#{school.name} will now process data"
        school.reload
        expect(school.process_data).to eq(true)
        click_on('Process data')
        school.reload
        expect(school.process_data).to eq(false)
      end

      it 'disallows data process management if the school has no meter readings' do
        school.update(process_data: false)
        click_on(school_name)
        click_on('Process data')
        expect(page).to have_content "#{school.name} cannot process data as it has no meter readings"
        school.reload
        expect(school.process_data).to eq(false)
      end

      it 'allows data enabled management from school page' do
        click_on(school_name)
        click_on('Data visible')
        school.reload
        expect(school).to_not be_data_enabled
        click_on('Data visible')
        school.reload
        expect(school).to be_data_enabled
      end

      it 'shows extra manage menu items' do
        visit school_path(school)
        expect(page).to have_css("#manage_school")
        expect(page).to have_link("Edit school details")
        expect(page).to have_link("Edit school times")
        expect(page).to have_link("School calendar")
        expect(page).to have_link("Manage users")
        expect(page).to have_link("Manage alert contacts")
        expect(page).to have_link("Manage meters")
        expect(page).to have_link("School configuration")
        expect(page).to have_link("Meter attributes")
        expect(page).to have_link("Manage CADs")
        expect(page).to have_link("Manage partners")
        expect(page).to have_link("Batch reports")
        expect(page).to have_link("Expert analysis")
        expect(page).to have_link("Remove school")
      end

      it 'displays reports path' do
        visit school_path(school)
        click_on 'Batch reports'
        expect(page).to have_link("Content reports")
        expect(page).to have_link("Alert reports")
        expect(page).to have_link("Email and SMS reports")
      end
    end
  end

  context 'as staff' do
    let(:staff)   { create(:staff, school: school) }

    before(:each) do
      sign_in(staff)
      visit school_path(school)
    end

    context 'with school menu' do
      it 'should have my school menu' do
        expect(page).to have_css("#my_school_menu")
        expect(page).to have_link("Electricity usage")
        expect(page).to have_link("Gas usage")
        expect(page).to have_link("Storage heater usage")
        expect(page).to have_link("Energy analysis")
        expect(page).to have_link("My alerts")
        expect(page).to have_link("School programmes")
        expect(page).to have_link("Complete pupil activities")
        expect(page).to have_link("Energy saving actions")
        expect(page).to have_link("Download our data")
      end

      it 'should display menu on other pages' do
        visit root_path
        expect(page).to have_css("#my_school_menu")
      end

      it 'should not have a manage menu' do
        expect(page).to_not have_css("#manage_school")
      end
    end

    context 'when displaying charts' do
      let(:dashboard_charts) { [] }

      before(:each) do
        school.configuration.update!(dashboard_charts: dashboard_charts)
        visit school_path(school)
      end

      context 'and they can all be shown' do
        let(:dashboard_charts) { [:management_dashboard_group_by_week_electricity, :management_dashboard_group_by_week_gas, :management_dashboard_group_by_week_storage_heater, :management_dashboard_group_by_month_solar_pv] }
        it 'displays the expected charts' do
          expect(page).to have_content("Recent energy usage")
          expect(page).to have_css("#management-energy-overview")
          expect(page).to have_css("#electricity-overview")
          expect(page).to have_css("#gas-overview")
          expect(page).to have_css("#storage_heater-overview")
          expect(page).to have_css("#solar-overview")
        end
      end

      context 'and there are limited charts' do
        let(:dashboard_charts) { [:management_dashboard_group_by_week_electricity, :management_dashboard_group_by_week_gas] }
        it 'displays the expected charts' do
          expect(page).to have_content("Recent energy usage")
          expect(page).to have_css("#management-energy-overview")
          expect(page).to have_css("#electricity-overview")
          expect(page).to have_css("#gas-overview")
          expect(page).to_not have_css("#storage_heater-overview")
          expect(page).to_not have_css("#solar-overview")
        end
      end

      context 'and there are no charts' do
        it 'displays the expected charts' do
          expect(page).to_not have_content("Recent energy usage")
          expect(page).to_not have_css("#management-energy-overview")
        end
      end
    end

    context 'with management priorities' do

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
            average_one_year_saving_gbp: '£5,000',
            average_capital_cost: '£2,000',
            one_year_saving_co2: '9,400 kg CO2',
            average_payback_years: '0 days'
          }
        )
      end

      before do
        Alerts::GenerateContent.new(school).perform
      end

      it 'displays the priorities in a table' do
        visit school_path(school)
        expect(page).to have_content('Spending too much money on heating')
        expect(page).to have_content('£2,000')
        expect(page).to have_content('£5,000')
        expect(page).to have_content('9,400 kg CO2')
        expect(page).to_not have_content('0 days')
      end

      it 'displays energy saving target prompt' do
        allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(true)
        allow_any_instance_of(::Targets::SchoolTargetService).to receive(:enough_data?).and_return(true)

        visit school_path(school)
        expect(page).to have_content("Set targets to reduce your school's energy consumption")
        expect(page).to have_link('Set energy saving target')

        school.school_targets << create(:school_target)
        visit school_path(school)
        expect(page).not_to have_content("Set targets to reduce your school's energy consumption")
      end

      it 'doesnt displays energy saving target prompt if not enough data' do
        allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(true)
        allow_any_instance_of(::Targets::SchoolTargetService).to receive(:enough_data?).and_return(false)

        visit school_path(school)
        expect(page).to_not have_content("Set targets to reduce your school's energy consumption")
      end

      it 'doesnt display prompt if feature disabled for school' do
        allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(true)
        school.update!(enable_targets_feature: false)
        visit school_path(school)
        expect(page).to_not have_content("Set targets to reduce your school's energy consumption")
      end

      it 'displays a report version of the page' do
        visit school_path(school)
        click_on 'Print view'
        expect(page).to have_content("Adult dashboard for #{school.name}")
        expect(page).to have_content('Spending too much money on heating')
        expect(page).to have_content('£2,000')
      end

    end

    context 'with dashboard alerts' do
      let!(:gas_fuel_alert_type) { create(:alert_type, fuel_type: :gas, frequency: :weekly) }
      let!(:alert_type_rating) do
        create(
          :alert_type_rating,
          alert_type: gas_fuel_alert_type,
          rating_from: 0,
          rating_to: 10,
          management_dashboard_alert_active: true,
        )
      end
      let!(:alert_type_rating_content_version) do
        create(
          :alert_type_rating_content_version,
          alert_type_rating: alert_type_rating,
          management_dashboard_title_en: 'You can save {{average_one_year_saving_gbp}} on heating in {{average_payback_years}}',
          management_dashboard_title_cy: 'Gallwch arbed {{average_one_year_saving_gbp}} mewn {{average_payback_years}}',
        )
      end
      let(:alert_summary){ 'Summary of the alert' }
      let!(:alert) do
        create(:alert, :with_run,
          alert_type: gas_fuel_alert_type,
          run_on: Date.today, school: school,
          rating: 9.0,
          template_data: {
            average_one_year_saving_gbp: '£5,000',
            average_payback_years: '1 year'
          },
          template_data_cy: {
            average_one_year_saving_gbp: '£7,000',
            average_payback_years: '1 flwyddyn'
          }
        )
      end

      before do
        Alerts::GenerateContent.new(school).perform
      end

      context 'in English' do
        it 'displays English alert text' do
          visit school_path(school)
          expect(page).to have_content('You can save £5,000 on heating in 1 year')
        end
      end

      context 'in Welsh' do
        it 'displays Welsh alert text' do
          visit school_path(school, locale: 'cy')
          expect(page).to have_content('Gallwch arbed £7,000 mewn 1 flwyddyn')
        end
      end
    end

    context 'with school targets' do
      let(:progress_summary) { nil }
      let!(:school_target)    { create(:school_target, school: school) }

      before(:each) do
        allow_any_instance_of(Targets::ProgressService).to receive(:progress_summary).and_return(progress_summary)
        visit school_path(school)
      end

      context 'and there is no data' do
        it 'has no notice' do
          expect(page).to_not have_content("Well done, you are making progress towards achieving your target")
          expect(page).to_not have_content("Unfortunately you are not meeting your targets")
        end
      end

      context 'that are being met' do
        let(:progress_summary)  { build(:progress_summary, school_target: school_target) }
        it 'displays a notice' do
          expect(page).to have_content("Well done, you are making progress towards achieving your target")
        end

        it 'links to target page' do
          expect(page).to have_link("Review progress", href: school_school_targets_path(school))
        end
      end

      context 'and gas is not being met' do
        let(:progress_summary)  { build(:progress_summary_with_failed_target, school_target: school_target) }

        it 'displays a notice' do
          expect(page).to have_content("Unfortunately you are not meeting your target to reduce your gas usage")
          expect(page).to have_content("Well done, you are making progress towards achieving your target to reduce your electricity and storage heater usage")
        end

        it 'links to target page' do
          expect(page).to have_link("Review progress", href: school_school_targets_path(school))
        end
      end

      context 'with lagging data' do
        let(:electricity_progress) { build(:fuel_progress, recent_data: false)}
        let(:progress_summary)  { build(:progress_summary, electricity: electricity_progress, school_target: school_target) }

        it 'displays a notice' do
          expect(page).to_not have_content("Unfortunately you are not meeting your target")
          expect(page).to have_content("Well done, you are making progress towards achieving your target to reduce your gas and storage heater usage")
        end

        it 'links to target page' do
          expect(page).to have_link("Review progress", href: school_school_targets_path(school))
        end
      end

    end

    context 'with co2 analysis' do
        before(:each) do
          co2_page = double(analysis_title: 'Some CO2 page', analysis_page: 'analysis/page/co2')
          expect_any_instance_of(SchoolsController).to receive(:process_analysis_templates).and_return([co2_page])
          visit school_path(school)
        end
        it 'shows link to co2 analysis page' do
          expect(page).to have_link("Some CO2 page")
        end
    end

    context 'with observations' do
      before(:each) do
        intervention_type = create(:intervention_type, name: 'Upgraded insulation')
        create(:observation, :intervention, school: school, intervention_type: intervention_type)
        create(:observation_with_temperature_recording_and_location, school: school)
        activity_type = create(:activity_type) # doesn't get saved if built with activity below
        create(:activity, school: school, activity_type: activity_type)
        visit school_path(school)
      end

      it 'displays interventions and temperature recordings in a timeline' do
        expect(page).to have_content('Recorded temperatures in')
        expect(page).to have_content('Upgraded insulation')
        expect(page).to have_content('Completed an activity')
        click_on 'View all events'
        expect(page).to have_content('Recorded temperatures in')
        expect(page).to have_content('Upgraded insulation')
        expect(page).to have_content('Completed an activity')
      end
    end

  end

  context 'as school admin' do
    let(:school_admin)  { create(:school_admin, school: school) }
    before(:each) do
      sign_in(school_admin)
      visit school_path(school)
    end

    context 'with school menu' do
      it 'should have my school menu' do
        expect(page).to have_css("#my_school_menu")
        expect(page).to have_link("Electricity usage")
        expect(page).to have_link("Gas usage")
        expect(page).to have_link("Storage heater usage")
        expect(page).to have_link("Energy analysis")
        expect(page).to have_link("My alerts")
        expect(page).to have_link("School programmes")
        expect(page).to have_link("Complete pupil activities")
        expect(page).to have_link("Energy saving actions")
        expect(page).to have_link("Download our data")
      end

      it 'should display menu on other pages' do
        visit root_path
        expect(page).to have_css("#my_school_menu")
      end

      it 'should have manage school menu' do
        expect(page).to have_css("#manage_school")
        expect(page).to have_link("Edit school details")
        expect(page).to have_link("Edit school times")
        expect(page).to have_link("School calendar")
        expect(page).to have_link("Manage users")
        expect(page).to have_link("Manage alert contacts")
        expect(page).to have_link("Manage meters")
      end
    end

  end

  context 'as pupil' do
    let(:pupil) { create(:pupil, school: school)}

    before(:each) do
      sign_in(pupil)
      visit school_path(school)
    end

    it 'does not display energy saving target prompt' do
      allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(true)
      allow_any_instance_of(::Targets::SchoolTargetService).to receive(:enough_data?).and_return(true)
      visit school_path(school)
      expect(page).to_not have_content("Set targets to reduce your school's energy consumption")
      expect(page).to_not have_link('Set energy saving target')
    end

  end

  context 'when school is not data-enabled' do
    before(:each) do
      school.update!(data_enabled: false)
    end

    context 'and not signed in' do
        before(:each) do
          visit school_path(school)
        end

        it 'does not show data-enabled features' do
          expect(page).to_not have_content("Annual usage summary")
        end

        it 'does not show data-enabled links' do
          within('.application') do
            expect(page).to_not have_link("Compare schools")
            expect(page).to_not have_link("Explore data")
            expect(page).to_not have_link("Review energy analysis")
          end
        end

        describe 'it does not show a loading page' do
          before(:each) do
            allow(AggregateSchoolService).to receive(:caching_off?).and_return(false)
            allow_any_instance_of(AggregateSchoolService).to receive(:aggregate_school).and_return(school)
          end

          it 'and redirects to pupil dashboard' do
            visit school_path(school)
            expect(page).to_not have_content("Adult Dashboard")
            expect(page).to_not have_content("Energy Sparks is processing all of this school's data to provide today's analysis")
            expect(page).to have_content("No activities completed, make a start!")
          end
        end
    end

    context 'and logged in as admin' do
      let!(:admin)    { create(:admin) }
      before(:each) do
        sign_in(admin)
        visit school_path(school)
      end

      it 'overrides flag and shows data-enabled features' do
        expect(page).to have_content("Summary of recent energy usage")
      end

      it 'overrides flag and shows data-enabled links' do
        expect(page).to have_link("Compare schools")
        expect(page).to have_link("Explore data")
        expect(page).to have_link("Review energy analysis")
        expect(page).to have_link("Download your data")
      end

      it 'shows link to user view' do
        expect(page).to have_link("User view")
        click_on("User view")
        expect(page).to have_link("Admin view")
        expect(page).to_not have_link("Explore data")
        expect(page).to_not have_content("Annual usage summary")
      end
    end

    context 'and signed in as staff' do
      let(:staff)   { create(:staff, school: school) }

      let!(:intervention)       { create(:observation, :temperature, school: school) }

      before(:each) do
        sign_in(staff)
        visit school_path(school)
      end

      it 'allows access to dashboard' do
        expect(page).to have_content("#{school.name}")
        expect(page).to have_content("Adult Dashboard")
      end

      it 'shows the expected prompts' do
        expect(page).to have_link("Find training")
        expect(page).to have_link("View your programmes")
        expect(page).to have_link("Record a pupil activity")
        expect(page).to have_link("Record an action")
      end

      it 'shows temperature observations' do
        #this is from the default observation created above
        expect(page).to have_content("Recorded temperatures")
      end

      it 'does not show data-enabled features' do
        expect(page).to_not have_content("Annual usage summary")
      end

      it 'shows placeholder chart' do
        expect(page).to have_css(".chart-placeholder-image")
      end

      it 'does not show data-enabled links' do
        within('.application') do
          expect(page).to_not have_link("Compare schools")
          expect(page).to_not have_link("Explore data")
          expect(page).to_not have_link("Review your energy analysis")
          expect(page).to_not have_link("Print view")
        end
      end

      it 'should not have data enabled features in my school menu' do
        expect(page).to have_css("#my_school_menu")
        expect(page).to_not have_link("Electricity usage")
        expect(page).to_not have_link("Gas usage")
        expect(page).to_not have_link("Storage heater usage")
        expect(page).to_not have_link("Energy analysis")
        expect(page).to have_link("My alerts")
        expect(page).to have_link("School programmes")
        expect(page).to have_link("Complete pupil activities")
        expect(page).to have_link("Energy saving actions")
        expect(page).to_not have_link("Download our data")
        expect(page).to_not have_link("Review targets")
      end
    end

    context 'and signed in as school admin' do
      let(:school_admin)  { create(:school_admin, school: school) }
      before(:each) do
        sign_in(school_admin)
        visit school_path(school)
      end

      it 'should not have data enabled features in my school menu' do
        expect(page).to have_css("#my_school_menu")
        expect(page).to_not have_link("Electricity usage")
        expect(page).to_not have_link("Gas usage")
        expect(page).to_not have_link("Storage heater usage")
        expect(page).to_not have_link("Energy analysis")
        expect(page).to have_link("My alerts")
        expect(page).to have_link("School programmes")
        expect(page).to have_link("Complete pupil activities")
        expect(page).to have_link("Energy saving actions")
        expect(page).to_not have_link("Download our data")
        expect(page).to_not have_link("Review targets")
      end

    end
  end
end
