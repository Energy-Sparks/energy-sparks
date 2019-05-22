require 'rails_helper'

module Alerts
  describe Alerts::Adapters::AnalyticsAdapter do

    class DummyAnalyticsAlertClass
      def initialize(aggregate_school)
        @aggregate_school = aggregate_school
      end

      def valid_alert?
        true
      end

      def analyse(_analysis_date)
      end

      def analysis_report
        @aggregate_school == nil ? self.class.bad_alert_report : self.class.good_alert_report
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

    class DummyAnalyticsAlertNotValidClass < DummyAnalyticsAlertClass
      def valid_alert?
        false
      end

      def self.alert_type(has_variables: true)
        FactoryBot.create :alert_type,
          class_name: 'Alerts::DummyAnalyticsAlertNotValidClass',
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

    context 'where the alert type does not have variables' do
      it 'does not add the variables to the report' do
        normalised_report = Adapters::AnalyticsAdapter.new(alert_type: DummyAnalyticsAlertClass.alert_type(has_variables: false), school: school, analysis_date: analysis_date, aggregate_school: aggregate_school).report
        expect(normalised_report.template_data).to eq({})
        expect(normalised_report.chart_data).to eq({})
        expect(normalised_report.table_data).to eq({})
      end
    end

    context 'when the alert is not valid' do
      it 'does not return a report' do
        expect(Adapters::AnalyticsAdapter.new(alert_type: DummyAnalyticsAlertNotValidClass.alert_type, school: school, analysis_date: analysis_date, aggregate_school: aggregate_school).report).to be nil
      end
    end
  end
end
