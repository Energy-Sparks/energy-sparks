require 'rails_helper'

class Alerts::DummyAlertClass
  def initialize(aggregate_school)
    @aggregate_school = aggregate_school
  end

  def analyse(_analysis_date)
  end

  def self.gas_fuel_alert_type(has_variables: true)
    AlertType.where(fuel_type: :gas, frequency: :weekly, class_name: 'Alerts::DummyAlertClass', description: 'Woof', title: 'Broken', has_variables: has_variables).first_or_create
  end

  def analysis_report
    @aggregate_school == nil ? Alerts::DummyAlertClass.bad_alert_report : Alerts::DummyAlertClass.good_alert_report
  end

  def front_end_template_data
    {template: 'variables'}
  end

  def front_end_template_charts
    {chart: 'variables'}
  end

  def front_end_template_tables
    {table: 'variables'}
  end


  def self.good_alert_report
    alert_report = AlertReport.new(AlertType.first)
    alert_report.summary = "This alert has run."
    alert_report.rating = 10.0
    alert_report.status = :good
    alert_report
  end

  def self.bad_alert_report
    alert_report = AlertReport.new(gas_fuel_alert_type)
    alert_report.summary = "There was a problem running the Broken alert. This is likely due to missing data."
    alert_report.status = :failed
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
      status: :good,
      data: {
        help_url: nil, detail: [], rating: 10.0 ,
        template_data: {template: 'variables'},
        chart_data: {chart: 'variables'},
        table_data: {table: 'variables'}
      }
    )
  end

  let(:bad_alert) do
    Alert.new(
      run_on: gas_date,
      summary: "There was a problem running the #{gas_fuel_alert_type.title} alert. This is likely due to missing data.",
      alert_type: gas_fuel_alert_type,
      status: :failed,
      data: {
        help_url: nil, detail: [], rating: nil,
        template_data: {},
        chart_data: {},
        table_data: {}
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

    context 'where the alert type does not have variables' do
      let!(:gas_fuel_alert_type) { Alerts::DummyAlertClass.gas_fuel_alert_type(has_variables: false)}
      let(:good_alert_without_data) do
        Alert.new(
          run_on: gas_date,
          summary: Alerts::DummyAlertClass.good_alert_report.summary,
          alert_type: gas_fuel_alert_type,
          status: :good,
          data: {
            help_url: nil, detail: [], rating: 10.0 ,
            template_data: {},
            chart_data: {},
            table_data: {}
          }
        )
      end
      it 'does not try and save the variables' do
        expect(Alerts::FrameworkAdapter.new(gas_fuel_alert_type, school, gas_date, aggregate_school).analyse).to have_attributes good_alert_without_data.attributes
      end
    end
  end
end
