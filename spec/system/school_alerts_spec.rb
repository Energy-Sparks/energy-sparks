require 'rails_helper'

RSpec.describe "school alerts", type: :system do
  let!(:school) { create(:school) }
  let!(:user)  { create(:user, school: school, role: :school_user)}
  let(:gas_fuel_alert_type_description) { 'all about this alert type' }
  let!(:gas_fuel_alert_type) { create(:alert_type, fuel_type: :gas, frequency: :termly, description: gas_fuel_alert_type_description) }

  let(:gas_date) { Date.parse('2019-01-01') }
  let!(:gas_meter) { create(:gas_meter_with_validated_reading_dates, school: school, start_date:gas_date - 1.day, end_date: gas_date) }

  context 'with generated reports' do
    it 'should show reports' do
      alert_summary = 'Summary of the alert'
      Alert.create(alert_type: gas_fuel_alert_type, run_on: gas_date, school: school, status: :good, data: { detail: [], rating: 10.0}, summary: alert_summary)
      sign_in(user)
      visit root_path

      click_on("Alerts")

      expect(Alert.first.title).to eq gas_fuel_alert_type.title
      expect(page.has_content?(alert_summary)).to be true
    end

    it 'should show only the latest report' do
      poor_alert_summary = 'POOR'
      good_alert_summary = 'GOOD'
      Alert.create(alert_type: gas_fuel_alert_type, run_on: gas_date, school: school, status: :poor, data: { detail: [], rating: 2.0}, summary: poor_alert_summary, created_at: DateTime.parse('2019-01-02'))
      Alert.create(alert_type: gas_fuel_alert_type, run_on: gas_date, school: school, status: :good, data: { detail: [], rating: 10.0}, summary: good_alert_summary, created_at: DateTime.parse('2019-01-02') + 10.minutes)
      sign_in(user)
      visit root_path
      click_on("Alerts")

      expect(page.has_content?(good_alert_summary)).to be true
      expect(page.has_content?(poor_alert_summary)).to_not be true
    end

    it 'can show a single report' do
      alert_summary = 'Summary of the alert'
      Alert.create(alert_type: gas_fuel_alert_type, run_on: gas_date, school: school, status: :good, data: { detail: [], rating: 10.0}, summary: alert_summary)
      sign_in(user)
      visit root_path
      click_on("Alerts")
      expect(page.has_content?(gas_fuel_alert_type_description)).to_not be true

      click_on("Find out more")

      expect(page.has_content?(gas_fuel_alert_type_description)).to be true
      expect(page.has_content?(alert_summary)).to be true
    end
  end

  context 'with no generated reports' do
    it 'should show reports' do
      sign_in(user)
      visit root_path
      click_on("Alerts")
      expect(page.has_content?("We have no termly alert data for this school")).to be true
      expect(page.has_content?("We have no weekly alert data for this school")).to be true
    end
  end
end
