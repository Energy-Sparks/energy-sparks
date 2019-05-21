require 'rails_helper'

describe Alerts::Adapters::AnalyticsAdapter do

  class Alerts::DummyAnalyticsAlertClass
    def initialize(aggregate_school)
      @aggregate_school = aggregate_school
    end

    def analyse(_analysis_date)
    end

    def status
      :good
    end

    def rating
      5.0
    end

    def front_end_template_data
      {template: 'variables'}
    end

    def front_end_template_chart_data
      {chart: 'variables'}
    end

    def front_end_template_table_data
      {table: 'variables'}
    end

    def self.alert_type(has_variables: true)
      FactoryBot.create :alert_type,
        class_name: 'Alerts::DummyAnalyticsAlertClass',
        has_variables: has_variables,
        source: :analytics
    end

  end

  let(:school) { build(:school) }
  let(:aggregate_school) { double :aggregate_school  }

  let(:analysis_date) { Date.parse('2019-01-01') }


  it 'should return an analysis report' do
    normalised_report = Alerts::Adapters::AnalyticsAdapter.new(alert_type: Alerts::DummyAnalyticsAlertClass.alert_type, school: school, analysis_date: analysis_date, aggregate_school: aggregate_school).report
    expect(normalised_report.status).to eq :good
    expect(normalised_report.rating).to eq 5.0
    expect(normalised_report.template_data).to eq({template: 'variables'})
    expect(normalised_report.chart_data).to eq({chart: 'variables'})
    expect(normalised_report.table_data).to eq({table: 'variables'})
  end

end
