require 'rails_helper'

RSpec.shared_examples 'managing targets', include_application_helper: true do
  let!(:gas_meter)         { create(:gas_meter, school: test_school) }
  let!(:electricity_meter) { create(:electricity_meter, school: test_school) }

  let(:fuel_configuration)   do
    Schools::FuelConfiguration.new(
      has_solar_pv: false, has_storage_heaters: true, fuel_types_for_analysis: :electric, has_gas: true, has_electricity: true)
  end

  let(:aggregate_meter_dates) do
    {
      "electricity": {
        "start_date": '2021-12-01',
        "end_date": '2022-02-01'
      },
      "gas": {
        "start_date": '2021-03-01',
        "end_date": '2022-02-01'
      }
    }
  end

  before do
    allow_any_instance_of(TargetsService).to receive(:enough_data_to_set_target?).and_return(true)
    allow_any_instance_of(TargetsService).to receive(:annual_kwh_estimate_required?).and_return(false)
    allow_any_instance_of(TargetsService).to receive(:recent_data?).and_return(true)

    # Update the configuration rather than creating one, as the school factory builds one
    # and so if we call create(:configuration, school: school) we end up with 2 records for a has_one
    # relationship
    test_school.configuration.update!(fuel_configuration: fuel_configuration, aggregate_meter_dates: aggregate_meter_dates)
    # So tests for 'prompts always show on dashboard' we need to set months_between to always be below the threshold for filtering
    allow_any_instance_of(Targets::SuggestEstimatesService).to receive(:months_between) { Targets::SuggestEstimatesService::THRESHOLD_FOR_FILTERING - 1 }

    sign_in(user) if user.present?
  end

  context 'when school has no target' do
    let(:last_year) { Time.zone.today.last_year }

    context 'with all fuel types' do
      before do
        visit school_school_targets_path(school)
      end

      it 'prompts to create first target' do
        expect(page).to have_content('Set your first energy saving target')
      end

      it 'links to help page if there is one' do
        create(:help_page, title: 'Targets', feature: :school_targets, published: true)
        refresh
        expect(page).to have_link('Help')
      end

      it 'allows targets for all fuel types to be set' do
        fill_in 'Reducing electricity usage by', with: 15
        fill_in 'Reducing gas usage by', with: 15
        fill_in 'Reducing storage heater usage by', with: 25

        click_on 'Set this target'

        expect(page).to have_content('Target successfully created')
        expect(school.has_current_target?).to be(true)
        expect(school.current_target.electricity).to be 15.0
        expect(school.current_target.gas).to be 15.0
        expect(school.current_target.storage_heaters).to be 25.0
      end

      it 'allows just gas and electricity targets to be set' do
        fill_in 'Reducing electricity usage by', with: 15
        fill_in 'Reducing storage heater usage by', with: ''
        click_on 'Set this target'
        expect(page).to have_content('Target successfully created')
        expect(school.has_current_target?).to be(true)
        expect(school.current_target.electricity).to be 15.0
        expect(school.current_target.gas).to be 10.0
        expect(school.current_target.storage_heaters).to be nil
      end

      it 'allows start date to be specified' do
        start_date = 1.month.ago.to_date
        fill_in 'Start date', with: start_date.strftime('%d/%m/%Y')
        click_on 'Set this target'
        expect(page).to have_content('Target successfully created')
        expect(school.most_recent_target.start_date).to eql start_date
        expect(school.most_recent_target.target_date).to eql start_date.next_year
      end

      it 'adds observation for target' do
        click_on 'Set this target'
        school.reload
        expect(school.current_target.observations.size).to be 1
      end
    end

    context 'with only electricity meters' do
      let(:fuel_configuration) do
        Schools::FuelConfiguration.new(
          has_solar_pv: false, has_storage_heaters: false, fuel_types_for_analysis: :electric, has_gas: false, has_electricity: true)
      end

      before do
        service_double = instance_double(AggregateSchoolService)
        allow(AggregateSchoolService).to receive(:new).with(school).and_return(service_double)
        allow(service_double).to receive(:aggregate_school)
          .and_return(build(:meter_collection, :with_aggregate_meter, kwh_data_x48: [1] * 48))
        visit school_school_targets_path(school)
      end

      it 'allows electricity target to be created' do
        expect(page).not_to have_content('Reducing gas usage by')
        expect(page).not_to have_content('Reducing storage heater usage by')

        fill_in 'Reducing electricity usage by', with: 15
        click_on 'Set this target'
        expect(page).to have_content('Target successfully created')
        expect(school.has_current_target?).to be(true)
        expect(school.current_target.electricity).to be 15.0
        expect(school.current_target.gas).to be nil
        expect(school.current_target.storage_heaters).to be nil
        expect(school.current_target.electricity_monthly_consumption).not_to be_nil
      end
    end
  end

  context 'viewing a current target' do
    let!(:target)             { create(:school_target, school: test_school) }
    let(:activity_type)       { create(:activity_type) }
    let(:intervention_type)   { create(:intervention_type) }
    let!(:expired_targets)    { }

    before do
      allow_any_instance_of(Recommendations::Actions).to receive(:based_on_energy_use).and_return([intervention_type])
      allow_any_instance_of(Recommendations::Activities).to receive(:based_on_energy_use).and_return([activity_type])
      visit school_school_targets_path(test_school)
    end

    it 'displays the current target page' do
      expect(page).to have_title('Your current energy saving targets')
    end

    context 'when there is a help page of the right type' do
      let!(:help_page) { create(:help_page, title: 'Targets', feature: :school_targets, published: true) }

      it 'links to it ' do
        refresh
        expect(page).to have_link('Help')
      end
    end

    it 'includes table footer' do
      expect(page).to have_content("Reporting change in energy usage between #{target.start_date.strftime('%B %Y')} and #{Time.zone.today.strftime('%B %Y')}")
    end

    it 'includes achieving your targets section' do
      expect(page).to have_content('Work with the pupils')
      expect(page).to have_link('Choose another activity', href: activity_categories_path)

      expect(page).to have_content('Take action around the school')
      expect(page).to have_link('Record an energy saving action', href: intervention_type_groups_path)

      expect(page).to have_content('Explore your data')
      expect(page).to have_link('View dashboard', href: school_path(test_school))
    end

    it 'includes links to activities' do
      expect(page).to have_link(activity_type.name, href: activity_type_path(activity_type))
    end

    it 'includes links to intervention types' do
      expect(page).to have_link(intervention_type.name, href: intervention_type_path(intervention_type))
    end

    it 'includes links to analysis' do
      expect(page).to have_link('Explore your data', href: pupils_school_analysis_path(test_school))
    end

    it 'redirects away from the new target form' do
      visit new_school_school_target_path(test_school, target)
      expect(page).to have_title('Your current energy saving targets')
    end

    context 'when an expired target is present' do
      let(:expired_target) { create(:school_target, school: test_school, start_date: Date.yesterday.prev_year, target_date: Date.yesterday) }
      let(:expired_targets) { [expired_target] }

      it 'links to expired target' do
        expect(page).to have_link('View results')
      end

      context "and clicking 'View results'" do
        before { click_on 'View results' }

        it 'shows previous expired target' do
          expect(page).to have_content("Your school set a target to reduce its energy usage between #{nice_dates(expired_target.start_date)} and #{nice_dates(expired_target.target_date)}")
        end

        it { expect(page).not_to have_link('View results') }

        context 'and there are progress reports for both targets' do
          let(:expired_target) do
            yesterday = Date.yesterday
            create(:school_target,
                   school: test_school,
                   start_date: yesterday.prev_year, target_date: yesterday,
              electricity: 2, gas: 4,
                   electricity_progress: build(:fuel_progress, fuel_type: :electricity, progress: 0.99, target: 20,
                                                               usage: 15),
                   gas_progress: build(:fuel_progress, fuel_type: :gas, progress: 0.59, target: 19, usage: 17),
                   report_last_generated: yesterday)
          end

          before do
            create(:school_target,
                   school: test_school, electricity: 10, gas: 10, storage_heaters: nil,
                   electricity_progress: build(:fuel_progress, fuel_type: :electricity, progress: 0.90, target: 15,
                                                               usage: 15),
                   gas_progress: build(:fuel_progress, fuel_type: :gas, progress: 0.50, target: 7, usage: 17),
                   report_last_generated: Time.zone.today)
          end

          it 'links to expired progress report' do
            # Extra check for debugging flickering test
            expect(Schools::Configuration.count).to be 1
            expect(School.first.has_electricity?).to be true
            expect(page).to have_link('View monthly report', href: electricity_school_school_target_progress_index_path(test_school, expired_target))
          end

          it 'shows progress summary' do
            def expect_row_to_have_target_and_progress(id, target, progress)
              expect(find(id)).to have_content("#{target.round(1)}%").and \
                have_content("#{(progress['progress'] * 100).round(0)}&percnt")
            end

            expect_row_to_have_target_and_progress('#electricity-row', expired_target.electricity,
                                                   expired_target.electricity_progress)
            expect_row_to_have_target_and_progress('#gas-row', expired_target.gas, expired_target.gas_progress)
          end
        end

        context 'more than one expired targets' do
          let(:older_expired_target) { create(:school_target, school: test_school, start_date: Date.yesterday.years_ago(2), target_date: Date.yesterday.years_ago(1)) }
          let(:expired_targets) { [expired_target, older_expired_target] }

          it 'shows previous expired target' do
            expect(page).to have_content("Your school set a target to reduce its energy usage between #{nice_dates(expired_target.start_date)} and #{nice_dates(expired_target.target_date)}")
          end
        end

        context 'no more expired targets' do
          it { expect(page).not_to have_link('View results') }
        end
      end
    end

    context 'no expired target' do
      it { expect(page).not_to have_link('View results') }
    end

    context 'and I edit the target' do
      before do
        click_on 'Revise your target'
      end

      it 'allows target to be edited' do
        expect(page).to have_content('Update your energy saving target')
        fill_in 'Reducing electricity usage by', with: 7
        fill_in 'Reducing gas usage by', with: 7
        fill_in 'Reducing storage heater usage by', with: 7
        click_on 'Update our target'
        expect(page).to have_content('Target successfully updated')
        expect(test_school.current_target.electricity).to be 7.0
        expect(test_school.current_target.gas).to be 7.0
        expect(test_school.current_target.storage_heaters).to be 7.0
      end

      it 'does not show a delete button' do
        expect(page).not_to have_link('Delete') unless user.admin?
      end

      it 'validates target values' do
        fill_in 'Reducing gas usage by', with: 123
        click_on 'Update our target'
        expect(page).to have_content('Gas must be less than or equal to 100')
      end
    end

    context 'and target has not yet been generated' do
      let!(:target) { create(:school_target, school: test_school, report_last_generated: nil) }

      it 'displays message to come back tomorrow' do
        expect(page).to have_content('We are calculating your progress')
        expect(page).to have_content('Check back tomorrow to see the results.')
        expect(page).not_to have_link('View progress', href: electricity_school_progress_index_path(school))
      end
    end

    context 'with a target progress report generated' do
      let!(:electricity_progress) { build(:fuel_progress, fuel_type: :electricity, progress: 0.99, target: 20, usage: 15) }
      let!(:gas_progress)         { build(:fuel_progress, fuel_type: :gas, progress: 0.59, target: 19, usage: 17) }
      let!(:last_generated)       { Time.zone.today }

      let!(:target)               do
        create(:school_target, storage_heaters: nil, school: test_school,
        electricity_progress: electricity_progress, gas_progress: gas_progress, report_last_generated: last_generated)
      end

      before do
        visit school_school_targets_path(test_school)
      end

      context 'with not enough data for electricity' do
        let!(:electricity_progress) { {} }
        let!(:gas_progress)         { build(:fuel_progress, fuel_type: :gas, progress: 0.59, target: 19, usage: 17) }
        let!(:last_generated)       { Time.zone.today }

        before do
          school.configuration.update!(suggest_estimates_fuel_types: ['electricity'])
          visit school_school_targets_path(test_school)
        end

        it 'cannot show any progress with no recent data at all' do
          within('#electricity-row') do
            expect(page).to have_content('N/A')
          end
        end

        context 'when there is recent management data' do
          let(:management_data) do
            Tables::SummaryTableData.new({ electricity: { year: { :percent_change => 0.11050 }, workweek: { :kwh => 100, :percent_change => -0.0923132131 } } })
          end

          before do
            allow_any_instance_of(Schools::ManagementTableService).to receive(:management_data).and_return(management_data)
            refresh
          end

          it 'shows the same data as the management dashboard' do
            within('#electricity-row') do
              expect(page).to have_content("-#{target.electricity.to_f}%") # target
              expect(page).to have_content('9.2%') # % change workweek
              expect(page).to have_content('last week')
            end
          end

          it 'still shows the full progress summary for gas' do
            within('#gas-row') do
              expect(page).to have_content("-#{target.gas.to_f}%") # target
              expect(page).to have_content('59&percnt;') # % change workweek
              expect(page).not_to have_content('last week')
            end
          end
        end
      end

      context 'where there is progress data' do
        it 'links to progress pages' do
          # Extra check for debugging flickering test
          expect(Schools::Configuration.count).to be 1
          expect(School.first.has_electricity?).to be true
          expect(page).to have_link('View monthly report', href: electricity_school_school_target_progress_index_path(test_school, target))
        end

        it 'shows detailed progress data' do
          within('#electricity-row') do
            expect(page).to have_content("-#{target.electricity.to_f}%") # target
            expect(page).to have_content('99&percnt;') # progress
            expect(page).not_to have_content('last week')
          end
          within('#gas-row') do
            expect(page).to have_content("-#{target.gas.to_f}%") # target
            expect(page).to have_content('59&percnt;') # progress
            expect(page).not_to have_content('last week')
          end
        end

        context 'and fuel types are out of date' do
          let!(:electricity_progress) { build(:fuel_progress, fuel_type: :electricity, progress: 0.99, target: 20, usage: 15, recent_data: false) }
          let!(:gas_progress)         { build(:fuel_progress, fuel_type: :gas, progress: 0.59, target: 19, usage: 17, recent_data: false) }

          before do
            # both gas and electricity will be out of date
            visit school_school_targets_path(test_school)
          end

          it 'displays a warning' do
            expect(page).to have_content('We have not received data for your electricity and gas usage for over thirty days')
          end
        end
      end

      context 'when fuel configuration has changed' do
        let!(:target) do
          create(:school_target, storage_heaters: nil, school: test_school,
          electricity_progress: electricity_progress, gas_progress: gas_progress, revised_fuel_types: ['storage_heater'])
        end

        it 'displays a prompt to revisit the target' do
          visit school_school_targets_path(test_school)
          expect(page).to have_content('Your Storage heater configuration has changed')
        end

        context 'when a storage heater was added' do
          before do
            visit school_school_targets_path(test_school)
            click_on('Review your target')
          end

          it 'displays the relevant field' do
            expect(page).to have_content('Reducing storage heater usage by')
          end

          it 'includes a prompt on the form' do
            expect(page).to have_content('Your Storage heater configuration has changed')
          end

          it 'no longer prompts after target is revised' do
            click_on 'Update our target'
            expect(page).not_to have_content('Your Storage heater configuration has changed')
            target.reload
            expect(target.suggest_revision?).to be false
            expect(school.current_target.storage_heaters).to eql Targets::SchoolTargetService::DEFAULT_STORAGE_HEATER_TARGET
          end
        end
      end

      context 'when an estimate would be useful' do
        before do
          school.configuration.update!(suggest_estimates_fuel_types: ['electricity'])
          visit school_school_targets_path(test_school)
        end

        it 'no longer prompts to add estimate' do
          expect(page).not_to have_content('If you can supply an estimate of your annual consumption then we can generate a more detailed progress report for your electricity')
        end

        it 'no longer shows the prompt on school dashboard' do
          visit school_path(test_school)
          expect(page).not_to have_content('Add an estimate of your annual electricity consumption')
        end
      end
    end
  end

  context 'viewing an expired target' do
    let!(:electricity_progress) { build(:fuel_progress, fuel_type: :electricity, progress: 0.99, target: 20, usage: 15) }
    let!(:gas_progress)         { build(:fuel_progress, fuel_type: :gas, progress: 0.59, target: 19, usage: 17) }
    let!(:last_generated)       { Date.yesterday }
    let!(:start_date)           { Date.yesterday.prev_year }
    let!(:target_date)          { Date.yesterday }
    let!(:target) { create(:school_target, school: test_school, start_date: start_date, target_date: target_date, electricity_progress: electricity_progress, gas_progress: gas_progress, report_last_generated: last_generated) }

    before do
      visit school_school_target_path(test_school, target)
    end

    it 'displays a different title' do
      expect(page).to have_title('Results of reducing your energy usage')
    end

    it 'prompts to review says target is expired' do
      expect(page).to have_content("It's now time to review your progress")
    end

    it 'includes summary of the target dates' do
      expect(page).to have_content("Your school set a target to reduce its energy usage between #{target.start_date.to_fs(:es_full)} and #{target.target_date.to_fs(:es_full)}")
    end

    it 'prompts to create a new target' do
      expect(page).not_to have_link('Revise your target')
      expect(page).to have_link('Set a new target')
      expect(page).to have_content("It's now time to review your progress")
      click_on('Set a new target', match: :first)
      expect(page).to have_content('Review and set your next energy saving target')
    end

    it 'includes table footer' do
      expect(page).to have_content("Reporting change in energy usage between #{start_date.strftime('%B %Y')} and #{target_date.strftime('%B %Y')}")
    end

    it 'redirects to this target from index' do
      visit school_school_targets_path(test_school)
      expect(page).to have_content("It's now time to review your progress")
    end

    it 'shows timeline' do
      expect(page).to have_content('How did you achieve your target?')
      expect(page).to have_content("You didn't record any energy saving activities or actions")
    end

    it 'disallows me from editing an old target' do
      visit edit_school_school_target_path(test_school, target)
      expect(page).to have_content('Cannot edit an expired target')
    end

    context 'with activities' do
      let!(:intervention_type)  { create(:intervention_type, name: 'Upgraded insulation') }
      let!(:activity_type)      { create(:activity_type, name: 'Did something cool') }
      let!(:intervention)       { create(:observation, :intervention, school: test_school, intervention_type: intervention_type, at: start_date + 1.day)}
      let!(:activity)           { create(:activity, school: test_school, activity_type: activity_type, happened_on: target_date - 1.day) }

      before do
        refresh
      end

      it 'shows timeline' do
        expect(page).to have_content('A reminder of the energy saving activities and actions you recorded')
        expect(page).to have_content(activity_type.name)
        expect(page).to have_content(intervention_type.name)
      end
    end

    context 'it allows me to create a new target' do
      before do
        click_on('Set a new target', match: :first)
      end

      it 'saves a new target' do
        expect(find_field('Reducing electricity usage by').value).to eq target.electricity.to_s
        fill_in 'Reducing electricity usage by', with: 15
        click_on 'Set this target'
        expect(school.current_target.electricity).to be 15.0
        expect(school.current_target.gas).to eql target.gas
        expect(school.current_target.storage_heaters).to eql target.storage_heaters
        expect(page).to have_content('Target successfully created')
      end

      it 'redirects from the index to the new target when set' do
        click_on 'Set this target'
        # should now redirect here not old target
        visit school_school_targets_path(test_school)
        expect(page).to have_content('We are calculating your progress')
      end

      it 'allows me to still view the old target' do
        click_on 'Set this target'
        expect(page).to have_content('Target successfully created')
        visit school_school_target_path(test_school, target)
        expect(page).not_to have_content("It's now time to review your progress")
      end
    end

    context 'and there is a newer target' do
      let!(:newer_target) { create(:school_target, school: test_school, start_date: target_date, target_date: target_date + 1.year, electricity_progress: electricity_progress, gas_progress: gas_progress, report_last_generated: last_generated) }

      it 'does not prompt to create another new target' do
        refresh
        expect(page).to have_link('View current target')
        click_on 'View current target'
        expect(page).to have_title('Your current energy saving targets')
      end

      it 'includes summary of the target dates' do
        refresh
        expect(page).to have_content("Your school set a target to reduce its energy usage between #{target.start_date.to_fs(:es_full)} and #{target.target_date.to_fs(:es_full)}")
      end
    end
  end
end

RSpec.describe 'school targets', type: :system do
  let!(:school) { create(:school) }

  context 'as a school admin' do
    let!(:user) { create(:school_admin, school: school) }

    include_examples 'managing targets' do
      let(:test_school) { school }
    end

    context 'with targets disabled for school' do
      before do
        school.update!(enable_targets_feature: false)
      end

      it 'doesnt have a link to review targets' do
        visit school_path(school)
        expect(Targets::SchoolTargetService.targets_enabled?(school)).to be false
        within '#my-school-menu' do
          expect(page).not_to have_link('Review targets', href: school_school_targets_path(school))
        end
      end

      it 'redirects from target page' do
        visit school_school_targets_path(school)
        expect(page).to have_current_path(school_path(school))
      end
    end
  end

  context 'as staff' do
    let!(:user) { create(:staff, school: school) }

    include_examples 'managing targets' do
      let(:test_school) { school }
    end

    context 'with targets disabled for school' do
      before do
        school.update!(enable_targets_feature: false)
      end

      it 'doesnt have a link to review targets' do
        visit school_path(school)
        expect(Targets::SchoolTargetService.targets_enabled?(school)).to be false
        within '#my-school-menu' do
          expect(page).not_to have_link('Review targets', href: school_school_targets_path(school))
        end
      end

      it 'redirects from target page' do
        visit school_school_targets_path(school)
        expect(page).to have_current_path(school_path(school))
      end
    end
  end

  # Admins can delete
  # Admins can view debugging data
  # otherwise same as school admin
  context 'as an admin' do
    let(:user) { create(:admin) }

    include_examples 'managing targets' do
      let(:test_school) { school }
    end

    context 'when viewing a target' do
      let!(:target) { create(:school_target, school: school) }

      before do
        visit school_school_targets_path(school)
        click_on 'Revise your target'
      end

      it 'allows target to be deleted' do
        click_on 'Delete'
        expect(page).to have_content('Target successfully removed')
        expect(SchoolTarget.count).to be 0
      end
    end
  end

  # View targets only
  context 'as a guest user' do
    let!(:electricity_progress) { build(:fuel_progress, fuel_type: :electricity, progress: 0.99, target: 20, usage: 15) }
    let!(:target) { create(:school_target, school: school, electricity_progress: electricity_progress) }

    before do
      visit school_school_targets_path(school)
    end

    it 'lets me view a target' do
      expect(page).to have_content('Reducing your energy usage by')
    end

    it 'shows me a link to the report' do
      expect(page).to have_link('View monthly report', href: electricity_school_school_target_progress_index_path(school, target))
    end

    it 'doesnt have a revise link' do
      expect(page).not_to have_link('Revise your target')
    end

    it 'doesnt have action links' do
      expect(page).not_to have_link('Choose another activity')
      expect(page).not_to have_link('Record an energy saving action')
    end
  end

  # Currently view only, soon: same as school admin
  context 'as a pupil' do
    let!(:electricity_progress) { build(:fuel_progress, fuel_type: :electricity, progress: 0.99, target: 20, usage: 15) }
    let!(:target)               { create(:school_target, school: school, electricity_progress: electricity_progress) }

    let(:pupil) { create(:pupil, school: school)}

    before do
      sign_in(pupil)
      visit school_school_targets_path(school)
    end

    it 'lets me view a target' do
      expect(page).to have_content('Reducing your energy usage by')
    end

    it 'shows me a link to the report' do
      expect(page).to have_link('View monthly report', href: electricity_school_school_target_progress_index_path(school, target))
    end

    it 'doesnt have a revise link' do
      expect(page).not_to have_link('Revise your target')
    end

    it 'doesnt have action links' do
      expect(page).to have_link('Choose another activity')
    end

    context 'with targets disabled for school' do
      before do
        school.update!(enable_targets_feature: false)
      end

      it 'doesnt have a link to review targets' do
        expect(Targets::SchoolTargetService.targets_enabled?(school)).to be false
        within '#my-school-menu' do
          expect(page).not_to have_link('Review targets', href: school_school_targets_path(school))
        end
      end

      it 'redirects from target page' do
        visit school_school_targets_path(school)
        expect(page).to have_current_path(pupils_school_path(school))
      end
    end
  end
end
