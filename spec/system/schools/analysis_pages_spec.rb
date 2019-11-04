require 'rails_helper'

RSpec.describe "analysis page", type: :system do
  let!(:school) { create(:school) }
  let!(:user)  { create(:staff, staff_role: create(:staff_role, :teacher), school: school)}
  let(:description) { 'all about this alert type' }
  let!(:gas_fuel_alert_type) { create(:alert_type, source: :analysis, fuel_type: :gas, description: description) }
  let!(:gas_meter) { create :gas_meter_with_reading, school: school }

  before(:each) do
    sign_in(user)
  end

  context 'with generated alert' do

    let!(:alert_type_rating) do
      create(
        :alert_type_rating,
        alert_type: gas_fuel_alert_type,
        rating_from: 0,
        rating_to: 10,
        analysis_active: true
      )
    end
    let!(:alert_type_rating_content_version) do
      create(
        :alert_type_rating_content_version,
        alert_type_rating: alert_type_rating,
        analysis_title: 'You might want to think about heating',
        analysis_subtitle: 'This is what you need to do'
      )
    end
    let!(:alert) do
      Alert.create(alert_type: gas_fuel_alert_type, school: school, rating: 9.0)
    end

    before do
      Alerts::GenerateContent.new(school).perform
    end

    it 'shows the box on the page with the relevant template data' do
      allow_any_instance_of(SchoolAggregation).to receive(:aggregate_school).and_return(school)

      adapter = double(:adapter)
      allow(Alerts::FrameworkAdapter).to receive(:new).with(gas_fuel_alert_type, school, alert.run_on, school).and_return(adapter)
      allow(adapter).to receive(:content).and_return(
        [
          {type: :title, content: 'Heating advice'},
          {type: :html, content: '<h2>Turn your heating down</h2>'},
          {type: :chart_name, content: :benchmark}
        ]
      )
      visit school_path(school)
      click_on "Learn more about your school's energy use"

      expect(page).to have_content('You might want to think about heating')
      expect(page).to have_content("This is what you need to do")

      expect(page.all('.fas.fa-star').size).to eq(4)
      expect(page.all('.fas.fa-star-half-alt').size).to eq(1)

      click_on alert_type_rating_content_version.analysis_title
      within 'h1' do
        expect(page).to have_content('Heating advice')
      end
      within 'h2' do
        expect(page).to have_content('Turn your heating down')
      end

    end

  end
end
