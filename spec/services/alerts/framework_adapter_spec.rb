require 'rails_helper'

GAS_FUEL_ALERT_TYPE = AlertType.create(fuel_type: :gas, frequency: :weekly, class_name: 'Alerts::DummyAlertClass', description: 'Woof', title: 'Broken')

class Alerts::DummyAlertClass
  def initialize(aggregate_school)
    @aggregate_school = aggregate_school
  end

  def analyse(_analysis_date)
  end

  def analysis_report
    @aggregate_school == nil ? Alerts::DummyAlertClass.bad_alert_report : Alerts::DummyAlertClass.good_alert_report
  end

  def self.good_alert_report
    alert_report = AlertReport.new(AlertType.first)
    alert_report.summary = "This alert has run."
    alert_report.rating = 10.0
    alert_report
  end

  def self.bad_alert_report
    alert_report = AlertReport.new(GAS_FUEL_ALERT_TYPE)
    alert_report.summary = "There was a problem running the Broken alert. This is likely due to missing data."
    alert_report
  end
end

describe Alerts::FrameworkAdapter do

  let(:school) { build(:school) }
  let(:aggregate_school) { 'Hello' }
  let!(:gas_fuel_alert_type) { GAS_FUEL_ALERT_TYPE }
  let(:gas_date) { Date.parse('2019-01-01') }
  let(:good_alert) do
    Alert.new(
      run_on: gas_date,
      summary: Alerts::DummyAlertClass.good_alert_report.summary,
      alert_type: gas_fuel_alert_type,
      data: { help_url: nil, detail: [], rating: 10.0 }
    )
  end

  let(:bad_alert) do
    Alert.new(
      run_on: gas_date,
      summary: "There was a problem running the #{GAS_FUEL_ALERT_TYPE.title} alert. This is likely due to missing data.",
      alert_type: GAS_FUEL_ALERT_TYPE,
      data: { help_url: nil, detail: [], rating: nil }
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
