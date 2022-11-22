require 'rails_helper'

RSpec.shared_examples "managing targets" do
  let!(:gas_meter)         { create(:gas_meter, school: test_school) }
  let!(:electricity_meter) { create(:electricity_meter, school: test_school) }

  let(:fuel_configuration)   { Schools::FuelConfiguration.new(
    has_solar_pv: false, has_storage_heaters: true, fuel_types_for_analysis: :electric, has_gas: true, has_electricity: true) }

  let(:aggregate_meter_dates) {
    {
      "electricity": {
        "start_date": "2021-12-01",
        "end_date": "2022-02-01"
      },
      "gas": {
        "start_date": "2021-03-01",
        "end_date": "2022-02-01"
      }
    }
  }

  before(:each) do
    allow_any_instance_of(TargetsService).to receive(:enough_data_to_set_target?).and_return(true)
    allow_any_instance_of(TargetsService).to receive(:annual_kwh_estimate_required?).and_return(false)
    allow_any_instance_of(TargetsService).to receive(:recent_data?).and_return(true)

    #Update the configuration rather than creating one, as the school factory builds one
    #and so if we call create(:configuration, school: school) we end up with 2 records for a has_one
    #relationship
    test_school.configuration.update!(fuel_configuration: fuel_configuration, aggregate_meter_dates: aggregate_meter_dates)
    # So tests for 'prompts always show on dashboard' we need to set months_between to always be below the threshold for filtering
    allow_any_instance_of(Targets::SuggestEstimatesService).to receive(:months_between) { Targets::SuggestEstimatesService::THRESHOLD_FOR_FILTERING - 1 }

    sign_in(user) if user.present?
  end

  it 'has a link to review targets from my school menu' do
    visit school_path(test_school)
    within '#my_school_menu' do
      expect(page).to have_link("Review targets", href: school_school_targets_path(test_school))
    end
  end

  context 'with targets disabled for school' do
    before(:each) do
      school.update!(enable_targets_feature: false)
      visit school_path(test_school)
    end

    it 'doesnt have a link to review targets' do
      visit school_path(school)
      expect( Targets::SchoolTargetService.targets_enabled?(school) ).to be false
      within '#my_school_menu' do
        expect(page).to_not have_link("Review targets", href: school_school_targets_path(school))
      end
    end

    it 'redirects from target page' do
      visit school_school_targets_path(school)
      expect(page).to have_current_path(school_path(school))
    end
  end

  context "when school has no target" do

    let(:last_year)         { Date.today.last_year }

    context "with all fuel types" do
      before(:each) do
        visit school_school_targets_path(school)
      end

      it "prompts to create first target" do
        expect(page).to have_content("Set your first energy saving target")
      end

      it 'links to help page if there is one' do
        create(:help_page, title: "Targets", feature: :school_targets, published: true)
        refresh
        expect(page).to have_link("Help")
      end

      it "allows targets for all fuel types to be set" do
        fill_in "Reducing electricity usage by", with: 15
        fill_in "Reducing gas usage by", with: 15
        fill_in "Reducing storage heater usage by", with: 25

        click_on 'Set this target'

        expect(page).to have_content('Target successfully created')
        expect(page).to have_content("We are calculating your progress")
        expect(school.has_current_target?).to eql(true)
        expect(school.current_target.electricity).to eql 15.0
        expect(school.current_target.gas).to eql 15.0
        expect(school.current_target.storage_heaters).to eql 25.0
      end

      it "allows just gas and electricity targets to be set" do
        fill_in "Reducing electricity usage by", with: 15
        fill_in "Reducing storage heater usage by", with: ''
        click_on 'Set this target'
        expect(page).to have_content('Target successfully created')
        expect(page).to have_content("We are calculating your progress")
        expect(school.has_current_target?).to eql(true)
        expect(school.current_target.electricity).to eql 15.0
        expect(school.current_target.gas).to eql 5.0
        expect(school.current_target.storage_heaters).to eql nil
      end

      it 'allows start date to be specified' do
        fill_in 'Start date', with: last_year.strftime("%d/%m/%Y")
        click_on 'Set this target'
        expect(page).to have_content('Target successfully created')
        expect(school.most_recent_target.start_date).to eql last_year
        expect(school.most_recent_target.target_date).to eql last_year.next_year
      end

    end

    context "with only electricity meters" do
      let(:fuel_configuration)   { Schools::FuelConfiguration.new(
        has_solar_pv: false, has_storage_heaters: false, fuel_types_for_analysis: :electric, has_gas: false, has_electricity: true) }

      before(:each) do
        visit school_school_targets_path(school)
      end

      it "allows electricity target to be created" do
        expect(page).to_not have_content("Reducing gas usage by")
        expect(page).to_not have_content("Reducing storage heater usage by")

        fill_in "Reducing electricity usage by", with: 15
        click_on 'Set this target'
        expect(page).to have_content('Target successfully created')
        expect(page).to have_content("We are calculating your progress")
        expect(school.has_current_target?).to eql(true)
        expect(school.current_target.electricity).to eql 15.0
        expect(school.current_target.gas).to eql nil
        expect(school.current_target.storage_heaters).to eql nil
      end
    end
  end

  context "viewing a current target" do
    let!(:target)              { create(:school_target, school: test_school) }
    let!(:activity_type)       { create(:activity_type) }
    let!(:intervention_type)   { create(:intervention_type) }

    before(:each) do
      visit school_school_targets_path(test_school)
    end

    it "displays the current target page" do
      expect(page).to have_title("Your current energy saving targets")
    end

    it 'links to help page if there is one' do
      create(:help_page, title: "Targets", feature: :school_targets, published: true)
      refresh
      expect(page).to have_link("Help")
    end

    it 'includes table footer' do
      expect(page).to have_content("Reporting change in energy usage between #{target.start_date.strftime('%B %Y')} and #{Date.today.strftime('%B %Y')}")
    end

    it "includes achieving your targets section" do
      expect(page).to have_content("Work with the pupils")
      expect(page).to have_link("Choose another activity", href: activity_categories_path)

      expect(page).to have_content("Take action around the school")
      expect(page).to have_link('Record an energy saving action', href: intervention_type_groups_path)

      expect(page).to have_content("Explore your data")
      expect(page).to have_link("View dashboard", href: school_path(test_school))
    end

    it "includes links to activities" do
      expect(page).to have_link(activity_type.name, href: activity_type_path(activity_type))
    end

    it "includes links to intervention types" do
      expect(page).to have_link(intervention_type.name, href: intervention_type_path(intervention_type))
    end

    it "includes links to analysis" do
      expect(page).to have_link("Explore your data", href: pupils_school_analysis_path(test_school))
    end

    it "redirects away from the new target form" do
      visit new_school_school_target_path(test_school, target)
      expect(page).to have_title("Your current energy saving targets")
    end

    context 'and I edit the target' do
        before(:each) do
          click_on "Revise your target"
        end

        it "allows target to be edited" do
          expect(page).to have_content("Update your energy saving target")
          fill_in "Reducing electricity usage by", with: 7
          fill_in "Reducing gas usage by", with: 7
          fill_in "Reducing storage heater usage by", with: 7
          click_on 'Update our target'
          expect(page).to have_content('Target successfully updated')
          expect(test_school.current_target.electricity).to eql 7.0
          expect(test_school.current_target.gas).to eql 7.0
          expect(test_school.current_target.storage_heaters).to eql 7.0
        end

        it "does not show a delete button" do
          expect(page).to_not have_link("Delete")
        end

        it "validates target values" do
          fill_in "Reducing gas usage by", with: 123
          click_on 'Update our target'
          expect(page).to have_content('Gas must be less than or equal to 100')
        end
    end

    context "and target has not yet been generated" do
      let!(:target)              { create(:school_target, school: test_school, report_last_generated: nil) }

      it "displays message to come back tomorrow" do
        expect(page).to have_content("We are calculating your progress")
        expect(page).to have_content("Check back tomorrow to see the results.")
        expect(page).to_not have_link("View progress", href: electricity_school_progress_index_path(school))
      end
    end

    context "and the target progress report has been generated" do

      let!(:electricity_progress) { build(:fuel_progress, fuel_type: :electricity, progress: 0.99, target: 20, usage: 15) }
      let!(:gas_progress)         { build(:fuel_progress, fuel_type: :gas, progress: 0.59, target: 19, usage: 17) }
      let!(:last_generated)       { Date.today }

      let!(:target)               { create(:school_target, storage_heaters: nil, school: test_school,
        electricity_progress: electricity_progress, gas_progress: gas_progress, report_last_generated: last_generated) }

      before(:each) do
        visit school_school_targets_path(test_school)
      end

      context "but there not yet enough data" do
        let!(:electricity_progress) { {} }
        let!(:gas_progress)         { build(:fuel_progress, fuel_type: :gas, progress: 0.59, target: 19, usage: 17) }
        let!(:last_generated)       { Date.today }

        before(:each) do
          school.configuration.update!(suggest_estimates_fuel_types: ["electricity"])
          visit school_school_targets_path(test_school)
        end

        it 'cannot show progress with no recent data' do
          expect(page).to_not have_content("last week")
        end

        context 'and some recent management data' do
          let(:management_data) {
            Tables::SummaryTableData.new({ electricity: { year: { :percent_change => 0.11050 }, workweek: { :kwh => 100, :percent_change => -0.0923132131 } } })
          }
          before(:each) do
            allow_any_instance_of(Schools::ManagementTableService).to receive(:management_data).and_return(management_data)
            refresh
          end
          it 'shows the same data as the management dashboard' do
            expect(page).to have_content("last week")
          end
        end

      end

      context "where there is progress data" do

        it "links to progress pages" do
          #Extra check for debugging flickering test
          expect(Schools::Configuration.count).to eql 1
          expect(School.first.has_electricity?).to be true
          expect(page).to have_link("View monthly report", href: electricity_school_progress_index_path(test_school))
        end

        it 'shows detailed progress data' do
          expect(page).to have_content("99%")
          expect(page).to_not have_content("last week")
        end

        context "and fuel types are out of date" do
          let!(:electricity_progress) { build(:fuel_progress, fuel_type: :electricity, progress: 0.99, target: 20, usage: 15, recent_data: false) }
          let!(:gas_progress)         { build(:fuel_progress, fuel_type: :gas, progress: 0.59, target: 19, usage: 17, recent_data: false) }

          before(:each) do
            #both gas and electricity will be out of date
            visit school_school_targets_path(test_school)
          end

          it "displays a warning" do
            expect(page).to have_content("We have not received data for your electricity and gas usage for over thirty days")
          end
        end
      end

      context "and fuel configuration has changed" do
        let!(:target)               { create(:school_target, storage_heaters: nil, school: test_school,
          electricity_progress: electricity_progress, gas_progress: gas_progress, revised_fuel_types: ["storage_heater"]) }

        it "displays a prompt to revisit the target" do
          visit school_school_targets_path(test_school)
          expect(page).to have_content("Your Storage heater configuration has changed")
        end

        context "and storage heater was added" do
          before(:each) do
            visit school_school_targets_path(test_school)
            click_on("Review your target")
          end

          it "displays the relevant field" do
            expect(page).to have_content("Reducing storage heater usage by")
          end

          it "includes a prompt on the form" do
            expect(page).to have_content("Your Storage heater configuration has changed")
          end

          it "no longer prompts after target is revised" do
            click_on "Update our target"
            expect(page).to_not have_content("Your Storage heater configuration has changed")
            target.reload
            expect(target.suggest_revision?).to be false
            expect(school.current_target.storage_heaters).to eql Targets::SchoolTargetService::DEFAULT_STORAGE_HEATER_TARGET
          end

        end
      end

      context "and an estimate would be useful" do
        before(:each) do
          school.configuration.update!(suggest_estimates_fuel_types: ["electricity"])
          visit school_school_targets_path(test_school)
        end
        it 'shows prompt to add estimate' do
          expect(page).to have_content("If you can supply an estimate of your annual consumption then we can generate a more detailed progress report for your electricity")
        end

        it 'shows the prompt on school dashboard' do
          visit school_path(test_school)
          expect(page).to have_content("Add an estimate of your annual electricity consumption")
        end

      end
    end
  end

  context "viewing an expired target" do
    let!(:electricity_progress) { build(:fuel_progress, fuel_type: :electricity, progress: 0.99, target: 20, usage: 15) }
    let!(:gas_progress)         { build(:fuel_progress, fuel_type: :gas, progress: 0.59, target: 19, usage: 17) }
    let!(:last_generated)       { Date.yesterday }
    let!(:start_date)           { Date.yesterday.prev_year }
    let!(:target_date)          { Date.yesterday }
    let!(:target)          { create(:school_target, school: test_school, start_date: start_date, target_date: target_date, electricity_progress: electricity_progress, gas_progress: gas_progress, report_last_generated: last_generated) }

    before(:each) do
      visit school_school_target_path(test_school, target)
    end

    it "displays a different title" do
      expect(page).to have_title("Results of reducing your energy usage")
    end

    it 'prompts to review says target is expired' do
      expect(page).to have_content("It's now time to review your progress")
    end

    it 'includes summary of the target dates' do
      expect(page).to have_content("Your school set a target to reduce its energy usage between between #{target.start_date.to_s(:es_full)} and #{target.target_date.to_s(:es_full)}")
    end

    it "prompts to create a new target" do
      expect(page).to_not have_link("Revise your target")
      expect(page).to have_link("Set a new target")
      expect(page).to have_content("It's now time to review your progress")
      click_on("Set a new target", match: :first)
      expect(page).to have_content("Review and set your next energy saving target")
    end

    it 'includes table footer' do
      expect(page).to have_content("Reporting change in energy usage between #{start_date.strftime("%B %Y")} and #{target_date.strftime("%B %Y")}")
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
      expect(page).to have_content("Cannot edit an expired target")
    end

    context 'with activities' do
      let!(:intervention_type)  { create(:intervention_type, name: 'Upgraded insulation') }
      let!(:activity_type)      { create(:activity_type) }
      let!(:intervention)       { create(:observation, :intervention, school: test_school, intervention_type: intervention_type, at: start_date + 1.day)}
      let!(:activity)           { create(:activity, school: test_school, activity_type: activity_type, happened_on: target_date - 1.day) }

      before(:each) do
        refresh
      end

      it 'shows timeline' do
        expect(page).to have_content("A reminder of the energy saving activities and actions you recorded")
        expect(page).to have_content('Completed an activity')
        expect(page).to have_content('Upgraded insulation')
      end
    end

    context 'it allows me to create a new target' do
      before(:each) do
        click_on("Set a new target", match: :first)
      end

      it 'saves a new target' do
        expect( find_field("Reducing electricity usage by").value ).to eq target.electricity.to_s
        fill_in "Reducing electricity usage by", with: 15
        click_on 'Set this target'
        expect(school.current_target.electricity).to eql 15.0
        expect(school.current_target.gas).to eql target.gas
        expect(school.current_target.storage_heaters).to eql target.storage_heaters
        expect(page).to have_content('Target successfully created')
        expect(page).to have_content("We are calculating your progress")
      end

      it 'redirects from the index to the new target when set' do
        click_on 'Set this target'
        #should now redirect here not old target
        visit school_school_targets_path(test_school)
        expect(page).to have_content("We are calculating your progress")
      end

      it 'allows me to still view the old target' do
        click_on 'Set this target'
        expect(page).to have_content("We are calculating your progress")
        visit school_school_target_path(test_school, target)
        expect(page).to_not have_content("It's now time to review your progress")
      end

    end

    context 'and there is a newer target' do
      let!(:newer_target)          { create(:school_target, school: test_school, start_date: target_date, target_date: target_date + 1.year, electricity_progress: electricity_progress, gas_progress: gas_progress, report_last_generated: last_generated) }

      it "does not prompt to create another new target" do
        refresh
        expect(page).to have_link("View current target")
        click_on "View current target"
        expect(page).to have_title("Your current energy saving targets")
      end

      it 'includes summary of the target dates' do
        refresh
        expect(page).to have_content("Your school set a target to reduce its energy usage between between #{target.start_date.to_s(:es_full)} and #{target.target_date.to_s(:es_full)}")
      end
    end

  end

end

RSpec.describe 'school targets', type: :system do
  let!(:school)            { create(:school) }

  context 'as a school admin' do
    let!(:user)              { create(:school_admin, school: school) }

    include_examples "managing targets" do
      let(:test_school) { school }
    end
  end

  #Admins can delete
  #Admins can view debugging data
  #otherwise same as school admin
  # context 'as an admin' do
  #   let(:admin)           { create(:admin) }
  #
  #   before(:each) do
  #     sign_in(admin)
  #   end
  #
  #   it 'lets me view target data' do
  #     visit school_meters_path(school)
  #     expect(page).to have_link("View target data", href: admin_school_target_data_path(school))
  #   end
  #
  #   context 'when viewing a target' do
  #     let!(:target)          { create(:school_target, school: school) }
  #
  #     before(:each) do
  #       visit school_school_targets_path(school)
  #       click_on "Revise your target"
  #     end
  #
  #     it 'allows target to be deleted' do
  #       click_on "Delete"
  #       expect(page).to have_content("Target successfully removed")
  #       expect(SchoolTarget.count).to eql 0
  #     end
  #   end
  # end

  #View targets only
  # context 'as a guest user' do
  #   let!(:electricity_progress) { build(:fuel_progress, fuel_type: :electricity, progress: 0.99, target: 20, usage: 15) }
  #   let!(:target)               { create(:school_target, school: school, electricity_progress: electricity_progress) }
  #   before(:each) do
  #     visit school_school_targets_path(school)
  #   end
  #   it 'lets me view a target' do
  #     expect(page).to have_content("Reducing your energy usage by")
  #   end
  #   it 'shows me a link to the report' do
  #     expect(page).to have_link("View report", href: electricity_school_progress_index_path(school))
  #   end
  #   it 'doesnt have a revise link' do
  #     expect(page).to_not have_link("Revise your target")
  #   end
  #   it 'doesnt have action links' do
  #     expect(page).to_not have_link("Choose another activity")
  #     expect(page).to_not have_link("Record an energy saving action")
  #   end
  #
  #   it 'does not allow me to set new one if expired'
  # end

  #Currently view only, soon: same as school admin
  # context 'as a pupil' do
  #   let!(:electricity_progress) { build(:fuel_progress, fuel_type: :electricity, progress: 0.99, target: 20, usage: 15) }
  #   let!(:target)               { create(:school_target, school: school, electricity_progress: electricity_progress) }
  #
  #   let(:pupil)            { create(:pupil, school: school)}
  #   before(:each) do
  #     sign_in(pupil)
  #     visit school_school_targets_path(school)
  #   end
  #   it 'lets me view a target' do
  #     expect(page).to have_content("Reducing your energy usage by")
  #   end
  #   it 'shows me a link to the report' do
  #     expect(page).to have_link("View report", href: electricity_school_progress_index_path(school))
  #   end
  #   it 'doesnt have a revise link' do
  #     expect(page).to_not have_link("Revise your target")
  #   end
  #   it 'doesnt have action links' do
  #     expect(page).to have_link("Choose another activity")
  #   end
  #   it 'allows me to set new one if expired'
  # end

  #Same as school admin
  # context 'as a staff user' do
  #   let!(:staff)      { create(:staff, school: school) }
  #
  #   before(:each) do
  #     sign_in(staff)
  #     visit school_path(school)
  #   end
  #
  #   context "with no target" do
  #
  #     context "with all fuel types" do
  #       before(:each) do
  #         visit school_school_targets_path(school)
  #       end
  #
  #       it "prompts to create first target" do
  #         expect(page).to have_content("Set your first energy saving target")
  #       end
  #
  #       context "and all fuel types" do
  #         it "allows all targets to be set" do
  #           fill_in "Reducing electricity usage by", with: 15
  #           fill_in "Reducing gas usage by", with: 15
  #           fill_in "Reducing storage heater usage by", with: 25
  #
  #           click_on 'Set this target'
  #
  #           expect(page).to have_content('Target successfully created')
  #           expect(page).to have_content("We are calculating your progress")
  #           expect(school.has_current_target?).to eql(true)
  #           expect(school.current_target.electricity).to eql 15.0
  #           expect(school.current_target.gas).to eql 15.0
  #           expect(school.current_target.storage_heaters).to eql 25.0
  #         end
  #       end
  #     end
  #   end
  # end
end
