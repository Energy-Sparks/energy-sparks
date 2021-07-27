require 'rails_helper'

describe 'Management dashboard' do

  let!(:school_group){ create(:school_group) }
  let!(:school){ create(:school, school_group: school_group) }
  let(:staff){ create(:staff, school: school, staff_role: create(:staff_role, :management)) }
  let!(:intervention){ create(:observation, school: school) }

  describe 'when not logged in' do
    it 'prompts for login' do
      visit management_school_path(school)
      expect(page).to have_content("Sign in to Energy Sparks")
    end
  end

  context 'when logged in as staff' do
    before(:each) do
      sign_in(staff)
    end

    it 'allows login and access to management dashboard' do
      visit root_path
      expect(page).to have_content("#{school.name}")
      expect(page).to have_content("Management Dashboard")
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
        visit root_path
        expect(page).to have_content('Set some targets')
        expect(page).to have_link('Set energy saving target')

        school.school_targets << create(:school_target)
        visit root_path
        expect(page).not_to have_content('Set some targets')
      end

      it 'displays a report version of the page' do
        visit root_path
        click_on 'Report view'
        expect(page).to have_content("Management information for #{school.name}")
        expect(page).to have_content('Spending too much money on heating')
        expect(page).to have_content('£2,000')
      end
    end

  end

end
