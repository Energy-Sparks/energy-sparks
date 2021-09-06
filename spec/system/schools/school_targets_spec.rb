require 'rails_helper'

RSpec.describe 'school targets', type: :system do

  let!(:school)            { create(:school, indicated_has_storage_heaters: true) }
  let!(:gas_meter)         { create(:gas_meter, school: school) }
  let!(:electricity_meter) { create(:electricity_meter, school: school) }
  let!(:school_admin)      { create(:school_admin, school: school) }

  let(:fuel_configuration)   { Schools::FuelConfiguration.new(
    has_solar_pv: false, has_storage_heaters: true, fuel_types_for_analysis: :electric, has_gas: true, has_electricity: true) }

  before(:each) do
    allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(true)

    #Update the configuration rather than creating one, as the school factory builds one
    #and so if we call create(:configuration, school: school) we end up with 2 records for a has_one
    #relationship
    school.configuration.update!(fuel_configuration: fuel_configuration)
    sign_in(school_admin)
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
          expect(page).to have_content("Your energy saving target")
          expect(school.has_current_target?).to eql(true)
          expect(school.current_target.electricity).to eql 15.0
          expect(school.current_target.gas).to eql 15.0
          expect(school.current_target.storage_heaters).to eql 25.0
        end
      end

    end

    context "and only electricity" do
      let(:fuel_configuration)   { Schools::FuelConfiguration.new(
        has_solar_pv: false, has_storage_heaters: false, fuel_types_for_analysis: :electric, has_gas: false, has_electricity: true) }

      before(:each) do
        school.update!(indicated_has_storage_heaters: false)
        school.configuration.update!(fuel_configuration: fuel_configuration)
        visit school_school_targets_path(school)
      end

      it "allows electricity target to be created" do
        expect(page).to_not have_content("Reducing gas usage by")
        expect(page).to_not have_content("Reducing storage heater usage by")

        fill_in "Reducing electricity usage by", with: 15
        click_on 'Set this target'

        expect(page).to have_content('Target successfully created')
        expect(page).to have_content("Your energy saving target")
        expect(school.has_current_target?).to eql(true)
        expect(school.current_target.electricity).to eql 15.0
        expect(school.current_target.gas).to eql nil
        expect(school.current_target.storage_heaters).to eql nil
      end

    end

  end

  context "with target" do
    let!(:target)          { create(:school_target, school: school, storage_heaters: nil) }

    let!(:activity_type)   { create(:activity_type)}

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

    it "includes achieving your targets section" do
      expect(page).to have_content("Working with the pupils")
      expect(page).to have_link("Choose another activity", href: suggest_activity_school_path(school))
      expect(page).to have_link("Explore your data", href: pupils_school_analysis_path(school))
    end

    it "includes links to activities" do
      expect(page).to have_link(activity_type.name, href: activity_type_path(activity_type))
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

    context "and fuel configuration has changed" do

      context "and theres enough data" do
        before(:each) do
          allow_any_instance_of(Targets::SchoolTargetService).to receive(:enough_data?).and_return(true)
          target.update!(revised_fuel_types: ["storage heater"])
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
