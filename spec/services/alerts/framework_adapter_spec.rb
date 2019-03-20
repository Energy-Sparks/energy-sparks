require 'rails_helper'

class Alerts::DummyAlertClass
  def initialize(aggregate_school)
    @aggregate_school = aggregate_school
  end

  def analyse(_analysis_date)
  end

  def self.gas_fuel_alert_type
    AlertType.where(fuel_type: :gas, frequency: :weekly, class_name: 'Alerts::DummyAlertClass', description: 'Woof', title: 'Broken').first_or_create
  end

  def analysis_report
    @aggregate_school == nil ? Alerts::DummyAlertClass.bad_alert_report : Alerts::DummyAlertClass.good_alert_report
  end

  def raw_template_variables
    {raw: 'variables'}
  end

  def text_template_variables
    {text: 'variables'}
  end

  def self.good_alert_report
    alert_report = AlertReport.new(AlertType.first)
    alert_report.summary = "This alert has run."
    alert_report.rating = 10.0
    alert_report
  end

  def self.bad_alert_report
    alert_report = AlertReport.new(gas_fuel_alert_type)
    alert_report.summary = "There was a problem running the Broken alert. This is likely due to missing data."
    alert_report
  end
end

describe Alerts::FrameworkAdapter do

  let(:school) { build(:school) }
  let(:aggregate_school) { 'Hello' }
  let!(:gas_fuel_alert_type) { Alerts::DummyAlertClass.gas_fuel_alert_type }
  let(:gas_date) { Date.parse('2019-01-01') }
  let(:good_alert) do
    Alert.new(
      run_on: gas_date,
      summary: Alerts::DummyAlertClass.good_alert_report.summary,
      alert_type: gas_fuel_alert_type,
      data: {
        help_url: nil, detail: [], rating: 10.0 ,
        raw_template_variables: {raw: 'variables'},
        text_template_variables: {text: 'variables'}
      }
    )
  end

  let(:bad_alert) do
    Alert.new(
      run_on: gas_date,
      summary: "There was a problem running the #{gas_fuel_alert_type.title} alert. This is likely due to missing data.",
      alert_type: gas_fuel_alert_type,
      data: {
        help_url: nil, detail: [], rating: nil,
        raw_template_variables: {raw: 'variables'},
        text_template_variables: {text: 'variables'}
      }
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
