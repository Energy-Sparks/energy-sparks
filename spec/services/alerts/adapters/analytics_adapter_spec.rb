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

      def status
        :good
      end

      def rating
        5.0
      end

      def enough_data
        :enough
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

      def self.alert_type
        FactoryBot.create :alert_type,
          class_name: 'Alerts::DummyAnalyticsAlertClass',
          source: :analytics
      end

    end

    class DummyAnalyticsAlertFailedClass < DummyAnalyticsAlertClass
      def status
        :failed
      end

      def self.alert_type
        FactoryBot.create :alert_type,
          class_name: 'Alerts::DummyAnalyticsAlertFailedClass',
          source: :analytics
      end
    end

    class DummyAnalyticsAlertNoStatusClass < DummyAnalyticsAlertClass
      def status
        nil
      end

      def self.alert_type
        FactoryBot.create :alert_type,
          class_name: 'Alerts::DummyAnalyticsAlertNoStatusClass',
          source: :analytics
      end
    end

    class DummyAnalyticsAlertNotEnoughDataClass < DummyAnalyticsAlertClass
      def enough_data
        :not_enough
      end

      def self.alert_type
        FactoryBot.create :alert_type,
          class_name: 'Alerts::DummyAnalyticsAlertNotEnoughDataClass',
          source: :analytics
      end
    end

    class DummyAnalyticsAlertNotValidClass < DummyAnalyticsAlertClass
      def valid_alert?
        false
      end

      def self.alert_type
        FactoryBot.create :alert_type,
          class_name: 'Alerts::DummyAnalyticsAlertNotValidClass',
          source: :analytics
      end
    end

    let(:school) { build(:school) }
    let(:aggregate_school) { double :aggregate_school  }

    let(:analysis_date) { Date.parse('2019-01-01') }

    it 'should return an analysis report' do
      normalised_report = Alerts::Adapters::AnalyticsAdapter.new(alert_type: Alerts::DummyAnalyticsAlertClass.alert_type, school: school, analysis_date: analysis_date, aggregate_school: aggregate_school).report
      expect(normalised_report.valid).to eq true
      expect(normalised_report.status).to eq :good
      expect(normalised_report.enough_data).to eq :enough
      expect(normalised_report.rating).to eq 5.0
      expect(normalised_report.template_data).to eq({template: 'variables'})
      expect(normalised_report.chart_data).to eq({chart: 'variables'})
      expect(normalised_report.table_data).to eq({table: 'variables'})
    end

    context 'where the alert has failed' do
      it 'does not add the variables to the report' do
        normalised_report = Adapters::AnalyticsAdapter.new(alert_type: DummyAnalyticsAlertFailedClass.alert_type, school: school, analysis_date: analysis_date, aggregate_school: aggregate_school).report
        expect(normalised_report.template_data).to eq({})
        expect(normalised_report.chart_data).to eq({})
        expect(normalised_report.table_data).to eq({})
      end
    end

    context 'where the alert type does not have enough data' do
      it 'does not add the variables to the report' do
        normalised_report = Adapters::AnalyticsAdapter.new(alert_type: DummyAnalyticsAlertNotEnoughDataClass.alert_type, school: school, analysis_date: analysis_date, aggregate_school: aggregate_school).report
        expect(normalised_report.template_data).to eq({})
        expect(normalised_report.chart_data).to eq({})
        expect(normalised_report.table_data).to eq({})
      end
    end

    context 'where the alert type does not have a status' do
      it 'does not add the variables to the report' do
        normalised_report = Adapters::AnalyticsAdapter.new(alert_type: DummyAnalyticsAlertNoStatusClass.alert_type, school: school, analysis_date: analysis_date, aggregate_school: aggregate_school).report
        expect(normalised_report.template_data).to eq({})
        expect(normalised_report.chart_data).to eq({})
        expect(normalised_report.table_data).to eq({})
      end
    end

    context 'when the alert is not valid' do
      it 'returns an invalid report' do
        normalised_report = Adapters::AnalyticsAdapter.new(alert_type: DummyAnalyticsAlertNotValidClass.alert_type, school: school, analysis_date: analysis_date, aggregate_school: aggregate_school).report
        expect(normalised_report.valid).to eq false
        expect(normalised_report.status).to eq nil
        expect(normalised_report.enough_data).to eq nil
        expect(normalised_report.rating).to eq nil
      end
    end

  end
end
