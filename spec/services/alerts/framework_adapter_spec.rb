require 'rails_helper'

class Alerts::DummyAlertClass
  def initialize(aggregate_school)
    @aggregate_school = aggregate_school
  end

  def analyse(_analysis_date)
    raise NoMethodError if @aggregate_school == nil
    Alerts::DummyAlertClass.good_alert_report
  end

  def self.good_alert_report
    alert_report = AlertReport.new(AlertType.first)
    alert_report.summary = "This alert has run."
    alert_report.rating = 10.0
    alert_report
  end
end

describe Alerts::FrameworkAdapter do

  let(:school) { build(:school) }
  let(:aggregate_school) { 'Hello' }
  let!(:gas_fuel_alert_type) { create(:alert_type, fuel_type: :gas, frequency: :weekly, class_name: 'Alerts::DummyAlertClass') }
  let(:gas_date) { Date.parse('2019-01-01') }
  let(:good_alert) do
    Alert.new(
      run_on: gas_date,
      summary: Alerts::DummyAlertClass.good_alert_report.summary,
      alert_type: gas_fuel_alert_type,
      data: { help_url: nil, detail: [], rating: 10.0, type: gas_fuel_alert_type.attributes, term: nil }
    )
  end

  let(:bad_alert) do
    Alert.new(
      run_on: gas_date,
      summary: "There was a problem running this alert: #{gas_fuel_alert_type.title}.",
      alert_type: gas_fuel_alert_type,
      data: { help_url: nil, detail: [], rating: nil, type: gas_fuel_alert_type.attributes, term: nil }
    )
  end

  context 'framework adapter' do
    it 'should return an analysis report' do
      expect(Alerts::FrameworkAdapter.new(gas_fuel_alert_type, school, gas_date, aggregate_school).analyse).to have_attributes good_alert.attributes
    end

    it 'handles an exception' do
      expect(Alerts::FrameworkAdapter.new(gas_fuel_alert_type, school, gas_date, nil).analyse).to have_attributes bad_alert.attributes
    end
  end
end
