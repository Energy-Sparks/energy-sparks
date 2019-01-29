require 'rails_helper'

RSpec.describe "alert reports", type: :system do
  let!(:admin)  { create(:user, role: 'admin')}
  let!(:gas_fuel_alert_type) { create(:alert_type, fuel_type: :gas) }
  let!(:school) { create(:school) }
  let(:gas_date) { Date.parse('2019-01-01') }
  let!(:gas_meter) { create(:gas_meter_with_validated_reading_dates, school: school, start_date:gas_date - 1.day, end_date: gas_date) }

#  let(:electricity_date) { Date.parse('2019-02-01') }
#  let!(:electricity_fuel_alert_type) { create(:alert_type, fuel_type: :electricity) }
#  let!(:no_fuel_alert_type) { create(:alert_type, fuel_type: nil) }

  context 'with generated reports' do
    it 'should show reports' do
      alert_summary = 'Summary of the alert'
      Alert.create(alert_type: gas_fuel_alert_type, run_on: gas_date, school: school, status: :good, data: { detail: [], rating: 10.0}, summary: alert_summary)
      sign_in(admin)
      visit root_path
      click_on(school.name)
      click_on("Alerts")

      expect(Alert.first.title).to eq gas_fuel_alert_type.title
      expect(page.has_content?(alert_summary)).to be true
    end

    it 'should show only the latest report' do
      poor_alert_summary = 'POOR'
      good_alert_summary = 'GOOD'
      Alert.create(alert_type: gas_fuel_alert_type, run_on: gas_date, school: school, status: :poor, data: { detail: [], rating: 2.0}, summary: poor_alert_summary, created_at: DateTime.parse('2019-01-02'))
      Alert.create(alert_type: gas_fuel_alert_type, run_on: gas_date, school: school, status: :good, data: { detail: [], rating: 10.0}, summary: good_alert_summary, created_at: DateTime.parse('2019-01-02') + 10.minutes)
      sign_in(admin)
      visit root_path
      click_on(school.name)
      click_on("Alerts")

      expect(page.has_content?(good_alert_summary)).to be true
      expect(page.has_content?(poor_alert_summary)).to_not be true
    end
  end

  context 'with no generated reports' do
    it 'should show reports' do
      sign_in(admin)
      visit root_path
      click_on(school.name)
      click_on("Alerts")
      expect(page.has_content?("We have no electricity alert data for this school")).to be true
      expect(page.has_content?("We have no gas alert data for this school")).to be true
    end
  end
end
