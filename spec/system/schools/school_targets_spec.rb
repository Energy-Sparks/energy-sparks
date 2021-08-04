require 'rails_helper'

RSpec.describe 'school targets', type: :system do

  let!(:school)            { create(:school) }
  let!(:gas_meter)         { create(:gas_meter, school: school) }
  let!(:electricity_meter) { create(:electricity_meter, school: school) }
  let!(:school_admin)      { create(:school_admin, school: school) }

  before(:each) do
    sign_in(school_admin)
  end

  context "with no target" do
    before(:each) do
      visit school_school_targets_path(school)
    end

    it "prompts to create first target" do
      expect(page).to have_content("Set your first energy saving target")
    end

    it "allows target to be created" do
      fill_in "Reducing electricity usage by", with: 15
      fill_in "Reducing gas usage by", with: 15
      fill_in "Reducing storage heater usage by", with: 25

      click_on 'Set this target'

      expect(page).to have_content('Target successfully created')
      expect(page).to have_content("Your current energy saving target")
      expect(school.has_current_target?).to eql(true)
      expect(school.current_target.electricity).to eql 15.0
      expect(school.current_target.gas).to eql 15.0
      expect(school.current_target.storage_heaters).to eql 25.0
    end

  end

  context "with target" do
    let!(:target)          { create(:school_target, school: school) }

    before(:each) do
      visit school_school_targets_path(school)
    end

    it "displays current target" do
      expect(page).to have_content("Your current energy saving target")
    end

    it "links to progress pages" do
      expect(page).to have_link("View progress", href: electricity_school_progress_index_path(school))
    end

    it "allows target to be edited" do
      click_on "revise your target"
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
      click_on "revise your target"

      fill_in "Reducing gas usage by", with: 123
      click_on 'Update our target'

      expect(page).to have_content('Gas must be less than or equal to 100')
    end

    it "redirects from new target page" do
      visit new_school_school_target_path(school, target)
      expect(page).to have_content("Your current energy saving target")
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
