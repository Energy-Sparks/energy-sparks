require 'rails_helper'

RSpec.describe 'school targets', type: :system do

  let!(:school)            { create(:school) }
  let!(:gas_meter)         { create(:gas_meter, school: school) }
  let!(:electricity_meter) { create(:electricity_meter, school: school) }

  let(:fuel_configuration)   { Schools::FuelConfiguration.new(
    has_solar_pv: false, has_storage_heaters: true, fuel_types_for_analysis: :electric, has_gas: true, has_electricity: true) }

  let(:school_target_fuel_types) { ["gas", "electricity", "storage_heater"] }

  before(:each) do
    allow_any_instance_of(TargetsService).to receive(:enough_data_to_set_target?).and_return(true)
    allow_any_instance_of(TargetsService).to receive(:annual_kwh_estimate_required?).and_return(false)
    allow_any_instance_of(TargetsService).to receive(:recent_data?).and_return(true)

    allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(true)
    allow(EnergySparks::FeatureFlags).to receive(:active?).with(:school_targets_v2).and_return(false)

    #Update the configuration rather than creating one, as the school factory builds one
    #and so if we call create(:configuration, school: school) we end up with 2 records for a has_one
    #relationship
    school.configuration.update!(fuel_configuration: fuel_configuration, school_target_fuel_types: school_target_fuel_types)
  end

  context 'as a school admin' do
    let!(:school_admin)      { create(:school_admin, school: school) }

    before(:each) do
      sign_in(school_admin)
      visit school_path(school)
    end

    it 'doesnt let me view target data' do
      expect(page).to_not have_link("View target data", href: admin_school_target_data_path(school))
    end

    context 'when displaying menu links' do
      it 'has a link to review targets when I can set one' do
        expect(page).to have_link("Review targets", href: school_school_targets_path(school))
      end

      it 'has no link if not enough data' do
        school.configuration.update!(school_target_fuel_types: [])
        refresh
        expect(page).to_not have_link("Review targets", href: school_school_targets_path(school))
      end

      it 'does have a link if v2 of targets is active' do
        school.configuration.update!(school_target_fuel_types: [])
        allow(EnergySparks::FeatureFlags).to receive(:active?).with(:school_targets_v2).and_return(true)
        refresh
        expect(page).to have_link("Review targets", href: school_school_targets_path(school))
      end

    end

    context 'with targets disabled' do
      before(:each) do
        school.update!(enable_targets_feature: false)
      end

      it 'doesnt have a link to review targets' do
        visit school_path(school)
        expect( Targets::SchoolTargetService.targets_enabled?(school) ).to be false
        expect(page).to_not have_link("Review targets", href: school_school_targets_path(school))
      end

      it 'doesnt let me navigate there' do
        visit school_school_targets_path(school)
        expect(page).to have_current_path(management_school_path(school))
      end
    end

    context "with no target" do

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

        context "and all fuel types" do
          it "allows all targets to be set" do
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
        end

        it 'allows start date to be specified' do
          fill_in 'Start date', with: last_year.strftime("%d/%m/%Y")
          click_on 'Set this target'
          expect(page).to have_content('Target successfully created')
          expect(school.most_recent_target.start_date).to eql last_year
          expect(school.most_recent_target.target_date).to eql last_year.next_year
        end

      end

      context "and only electricity" do
        let(:fuel_configuration)   { Schools::FuelConfiguration.new(
          has_solar_pv: false, has_storage_heaters: false, fuel_types_for_analysis: :electric, has_gas: false, has_electricity: true) }

        before(:each) do
          school.configuration.update!(fuel_configuration: fuel_configuration, school_target_fuel_types: ["electricity"])
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

      context "and only enough data for electricity" do

        before(:each) do
          school.configuration.update!(fuel_configuration: fuel_configuration, school_target_fuel_types: ["electricity"])
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

    context "with newly created target" do
      let!(:target)          { create(:school_target, school: school, report_last_generated: nil) }

      before(:each) do
        visit school_school_targets_path(school)
      end

      it "displays message to come back tomorrow" do
        expect(page).to have_content("We are calculating your progress")
        expect(page).to have_content("Check back tomorrow to see the results.")
        expect(page).to_not have_link("View progress", href: electricity_school_progress_index_path(school))
      end

    end

    context "with target that has been generated" do
      let!(:electricity_progress) { build(:fuel_progress, fuel_type: :electricity, progress: 0.99, target: 20, usage: 15) }
      let!(:gas_progress)         { build(:fuel_progress, fuel_type: :gas, progress: 0.59, target: 19, usage: 17) }

      let!(:target)               { create(:school_target, storage_heaters: nil, school: school,
        electricity_progress: electricity_progress, gas_progress: gas_progress) }

      let!(:activity_type)   { create(:activity_type)}
      let!(:intervention_type)   { create(:intervention_type)}

      before(:each) do
        visit school_school_targets_path(school)
      end

      it "displays current target" do
        expect(page).to have_content("Your energy saving target")
      end

      it "links to progress pages" do
        #Extra check for debugging flickering test
        expect(Schools::Configuration.count).to eql 1
        expect(School.first.has_electricity?).to be true

        expect(page).to have_link("View progress", href: electricity_school_progress_index_path(school))
      end

      it 'shows the bullet charts' do
        expect(page).to have_css('#bullet-chart-electricity')
        expect(page).to have_css('#bullet-chart-gas')
        expect(page).to_not have_css('#bullet-chart-storage_heater')
      end

      it 'does not show limited data' do
        expect(page).to_not have_content("Goal")
        expect(page).to_not have_content("Last week")
      end

      context "and v2 is active and limited data is available" do
        before(:each) do
          allow(EnergySparks::FeatureFlags).to receive(:active?).with(:school_targets_v2).and_return(true)
          target.update!(electricity_progress: {})
          school.configuration.update!(suggest_estimates_fuel_types: ["electricity"])
          refresh
        end
        it 'doesnt show the electricity bullet chart' do
          expect(page).to_not have_css('#bullet-chart-electricity')
          expect(page).to have_css('#bullet-chart-gas')
        end

        it 'shows limited data' do
          expect(page).to have_content("Goal")
          expect(page).to_not have_content("Last week")
        end

        it 'shows prompt to add estimate' do
          expect(page).to have_content("If you can supply an estimate of your annual consumption then we can generate a detailed progress report")
        end

        context 'and some recent data' do
          let(:management_data) {
            Tables::SummaryTableData.new({ electricity: { year: { :percent_change => 0.11050 }, workweek: { :kwh => 100, :percent_change => -0.0923132131 } } })
          }
          before(:each) do
            allow_any_instance_of(Schools::ManagementTableService).to receive(:management_data).and_return(management_data)
            refresh
          end
          it 'shows the same data as the management dashboard' do
            expect(page).to have_content("Last week")
          end
        end
      end

      it 'links to help page if there is one' do
        create(:help_page, title: "Targets", feature: :school_targets, published: true)
        refresh
        expect(page).to have_link("Help")
      end

      it "includes achieving your targets section" do
        expect(page).to have_content("Working with the pupils")
        expect(page).to have_link("Choose another activity", href: activity_categories_path)

        expect(page).to have_content("Taking action around the school")
        expect(page).to have_link('Record an energy saving action', href: intervention_type_groups_path)

        expect(page).to have_content("Explore your data")
        expect(page).to have_link("View dashboard", href: management_school_path(school))
      end

      it "includes links to activities" do
        expect(page).to have_link(activity_type.name, href: activity_type_path(activity_type))
      end

      it "includes links to intervention types" do
        expect(page).to have_link(intervention_type.title, href: intervention_type_path(intervention_type))
      end

      it "includes links to analysis" do
        expect(page).to have_link("Explore your data", href: pupils_school_analysis_path(school))
      end

      it "allows target to be edited" do
        click_on "Revise your target"
        expect(page).to have_content("Update your energy saving target")

        fill_in "Reducing electricity usage by", with: 7
        fill_in "Reducing gas usage by", with: 7
        fill_in "Reducing storage heater usage by", with: 7

        click_on 'Update our target'

        expect(page).to have_content('Target successfully updated')

        expect(school.current_target.electricity).to eql 7.0
        expect(school.current_target.gas).to eql 7.0
        expect(school.current_target.storage_heaters).to eql 7.0
      end

      it "doesnt show delete button" do
        click_on "Revise your target"
        expect(page).to_not have_link("Delete")
      end

      it "validates target values" do
        click_on "Revise your target"

        fill_in "Reducing gas usage by", with: 123
        click_on 'Update our target'

        expect(page).to have_content('Gas must be less than or equal to 100')
      end

      it "redirects from new target page" do
        visit new_school_school_target_path(school, target)
        expect(page).to have_content("Your energy saving target")
      end

      context "and fuel types are out of date" do
        let!(:electricity_progress) { build(:fuel_progress, fuel_type: :electricity, progress: 0.99, target: 20, usage: 15, recent_data: false) }
        let!(:gas_progress)         { build(:fuel_progress, fuel_type: :gas, progress: 0.59, target: 19, usage: 17, recent_data: false) }

        before(:each) do
          #both gas and electricity will be out of date
          visit school_school_targets_path(school)
        end

        it "displays a warning" do
          expect(page).to have_content("We have not received data for your electricity and gas usage for over thirty days")
        end
      end

      context "and fuel configuration has changed" do

        context "and theres enough data" do
          before(:each) do
            target.update!(revised_fuel_types: ["storage_heater"])
          end

          it "displays a prompt to revisit the target" do
            visit school_school_targets_path(school)
            expect(page).to have_content("Your Storage heater configuration has changed")
          end

          context "and storage heater was added" do
            before(:each) do
              visit school_school_targets_path(school)
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
      end

    end

    context "with expired target" do
      let!(:target)          { create(:school_target, school: school, start_date: Date.yesterday.prev_year, target_date: Date.yesterday) }

      before(:each) do
        visit school_school_targets_path(school)
      end

      it "prompts to create new target" do
        expect(page).to have_content("Review and set your next energy saving target")
      end

      it "creates new target from old" do
        expect( find_field("Reducing electricity usage by").value ).to eq target.electricity.to_s

        fill_in "Reducing electricity usage by", with: 15

        click_on 'Set this target'

        expect(school.current_target.electricity).to eql 15.0
        expect(school.current_target.gas).to eql target.gas
        expect(school.current_target.storage_heaters).to eql target.storage_heaters
      end

    end
  end

  context 'as an admin' do
    let(:admin)           { create(:admin) }

    before(:each) do
      sign_in(admin)
    end

    it 'lets me view target data' do
      visit school_meters_path(school)
      expect(page).to have_link("View target data", href: admin_school_target_data_path(school))
    end

    context 'when viewing a target' do
      let!(:target)          { create(:school_target, school: school) }

      before(:each) do
        visit school_school_targets_path(school)
        click_on "Revise your target"
      end

      it 'allows target to be deleted' do
        click_on "Delete"
        expect(page).to have_content("Target successfully removed")
        expect(SchoolTarget.count).to eql 0
      end
    end
  end

  context 'as a guest user' do
    let!(:electricity_progress) { build(:fuel_progress, fuel_type: :electricity, progress: 0.99, target: 20, usage: 15) }
    let!(:target)               { create(:school_target, school: school, electricity_progress: electricity_progress) }
    before(:each) do
      visit school_school_targets_path(school)
    end
    it 'lets me view a target' do
      expect(page).to have_content("Your energy saving target")
    end
    it 'shows me a link to the report' do
      expect(page).to have_link("View progress", href: electricity_school_progress_index_path(school))
    end
    it 'doesnt have a revise link' do
      expect(page).to_not have_link("Revise your target")
    end
    it 'doesnt have action links' do
      expect(page).to_not have_link("Choose another activity")
      expect(page).to_not have_link("Record an energy saving action")
    end
  end

  context 'as a pupil' do
    let!(:electricity_progress) { build(:fuel_progress, fuel_type: :electricity, progress: 0.99, target: 20, usage: 15) }
    let!(:target)               { create(:school_target, school: school, electricity_progress: electricity_progress) }

    let(:pupil)            { create(:pupil, school: school)}
    before(:each) do
      sign_in(pupil)
      visit school_school_targets_path(school)
    end
    it 'lets me view a target' do
      expect(page).to have_content("Your energy saving target")
    end
    it 'shows me a link to the report' do
      expect(page).to have_link("View progress", href: electricity_school_progress_index_path(school))
    end
    it 'doesnt have a revise link' do
      expect(page).to_not have_link("Revise your target")
    end
    it 'doesnt have action links' do
      expect(page).to have_link("Choose another activity")
    end
  end

  context 'as a staff user' do
    let!(:staff)      { create(:staff, school: school) }

    before(:each) do
      sign_in(staff)
      visit school_path(school)
    end

    context "with no target" do

      context "with all fuel types" do
        before(:each) do
          visit school_school_targets_path(school)
        end

        it "prompts to create first target" do
          expect(page).to have_content("Set your first energy saving target")
        end

        context "and all fuel types" do
          it "allows all targets to be set" do
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
        end
      end
    end
  end
end
