require 'rails_helper'

describe Alerts::FrameworkAdapter do

  let(:school) { build(:school) }
  let(:aggregate_school) { double :aggregate_school }
  let!(:alert_type) { create :alert_type, source: :system}
  let(:gas_date) { Date.parse('2019-01-01') }
  let(:alert) do
    Alert.new(
      run_on: gas_date,
      alert_type: alert_type,
      rating: 5.0 ,
      enough_data: :enough,
      template_data: {template: 'variables'},
      chart_data: {chart: 'variables'},
      table_data: {table: 'variables'},
      priority_data: {priority: 'variables'}
    )
  end

  let(:alert_report) do
    Alerts::Adapters::Report.new(
      valid: true,
      rating: 5.0,
      enough_data: :enough,
      relevance: :relevant,
      template_data: {template: 'variables'},
      chart_data: {chart: 'variables'},
      table_data: {table: 'variables'},
      priority_data: {priority: 'variables'}
    )

  end

  it 'uses the adapters to create an alert object from the returned reports' do
    expect(Alerts::FrameworkAdapter.new(alert_type: alert_type, school: school, analysis_date: gas_date, aggregate_school: aggregate_school).analyse.to_json).to eq alert_report.to_json
  end

  it 'returns the date the alert would be run for' do
    pp alert_type

  end
end
