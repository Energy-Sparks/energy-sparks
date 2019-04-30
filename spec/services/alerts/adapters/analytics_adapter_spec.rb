require 'rails_helper'

describe Alerts::Adapters::AnalyticsAdapter do

  class Alerts::DummyAnalyticsAlertClass
    def initialize(aggregate_school)
      @aggregate_school = aggregate_school
    end

    def analyse(_analysis_date)
    end

    def analysis_report
      @aggregate_school == nil ? self.class.bad_alert_report : self.class.good_alert_report
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

    def self.alert_type(has_variables: true)
      FactoryBot.create :alert_type,
        class_name: 'Alerts::DummyAnalyticsAlertClass',
        has_variables: has_variables,
        source: :analytics
    end

    def self.good_alert_report
      alert_report = AlertReport.new(alert_type)
      alert_report.summary = "This alert has run."
      alert_report.rating = 10.0
      alert_report.status = :good
      alert_report
    end

    def self.bad_alert_report
      alert_report = AlertReport.new(alert_type)
      alert_report.summary = "There was a problem running the Broken alert. This is likely due to missing data."
      alert_report.status = :failed
      alert_report
    end

  end

  let(:school) { build(:school) }
  let(:aggregate_school) { double :aggregate_school  }

  let(:analysis_date) { Date.parse('2019-01-01') }


  it 'should return an analysis report' do
    normalised_report = Alerts::Adapters::AnalyticsAdapter.new(alert_type: Alerts::DummyAnalyticsAlertClass.alert_type, school: school, analysis_date: analysis_date, aggregate_school: aggregate_school).report
    good_alert_report = Alerts::DummyAnalyticsAlertClass.good_alert_report
    expect(normalised_report.summary).to eq good_alert_report.summary
    expect(normalised_report.status).to eq good_alert_report.status
    expect(normalised_report.template_data).to eq({template: 'variables'})
    expect(normalised_report.chart_data).to eq({chart: 'variables'})
    expect(normalised_report.table_data).to eq({table: 'variables'})
  end

  it 'handles an exception' do
    normalised_report = Alerts::Adapters::AnalyticsAdapter.new(alert_type: Alerts::DummyAnalyticsAlertClass.alert_type, school: school, analysis_date: analysis_date, aggregate_school: nil).report
    bad_alert_report = Alerts::DummyAnalyticsAlertClass.bad_alert_report
    expect(normalised_report.summary).to eq bad_alert_report.summary
    expect(normalised_report.status).to eq bad_alert_report.status
    expect(normalised_report.template_data).to eq({})
    expect(normalised_report.chart_data).to eq({})
    expect(normalised_report.table_data).to eq({})
  end

  context 'where the alert type does not have variables' do
    it 'does not add the variables to the report' do
      normalised_report = Alerts::Adapters::AnalyticsAdapter.new(alert_type: Alerts::DummyAnalyticsAlertClass.alert_type(has_variables: false), school: school, analysis_date: analysis_date, aggregate_school: aggregate_school).report
      expect(normalised_report.template_data).to eq({})
      expect(normalised_report.chart_data).to eq({})
      expect(normalised_report.table_data).to eq({})
    end
  end

end
