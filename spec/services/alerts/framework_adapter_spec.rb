require 'rails_helper'

describe Alerts::FrameworkAdapter do

  module Alerts
    module System
      class DummyAlert

        def initialize(args = {})
        end

        def report
          Alerts::Adapters::Report.new(
            status: :good,
            rating: 5.0,
            summary: 'The alert has run',
            template_data: {
              template: 'variables'
            },
            chart_data: {
              chart: 'variables'
            },
            table_data: {
              table: 'variables'
            }
          )
        end
      end
    end
  end

  let(:school) { build(:school) }
  let(:aggregate_school) { double :aggregate_school }
  let!(:alert_type) { create :alert_type, class_name: 'Alerts::System::DummyAlert', source: :system}
  let(:gas_date) { Date.parse('2019-01-01') }
  let(:alert) do
    Alert.new(
      run_on: gas_date,
      summary: 'The alert has run',
      alert_type: alert_type,
      status: :good,
      data: {
        help_url: nil, detail: [], rating: 5.0 ,
        template_data: {template: 'variables'},
        chart_data: {chart: 'variables'},
        table_data: {table: 'variables'}
      }
    )
  end

  it 'uses the adapters to create an alert object from the returned reports' do
    expect(Alerts::FrameworkAdapter.new(alert_type, school, gas_date, aggregate_school).analyse).to have_attributes alert.attributes
  end
end
