# == Schema Information
#
# Table name: alert_types
#
#  analysis_description :text
#  fuel_type            :integer
#  daily_frequency      :integer
#  id                   :bigint(8)        not null, primary key
#  long_term            :boolean
#  sample_message       :text
#  short_term           :boolean
#  sub_category         :integer
#  title                :text
#
module Alerts
  module System
    class DummyAlert
      def initialize(args = {})
      end

      def report
        Alerts::Adapters::Report.new(
          valid: true,
          rating: 5.0,
          enough_data: :enough,
          relevance: :relevant,
          template_data: {
            template: 'variables'
          },
          chart_data: {
            chart: 'variables'
          },
          table_data: {
            table: 'variables'
          },
          priority_data: {
            priority: 'variables'
          }
        )
      end

      def front_end_template_chart_data
      end

      def benchmark_dates(asof_date)
        [asof_date, asof_date - 1.year]
      end

      def self.front_end_template_charts
        TEMPLATE_VARIABLES.select {|_key, value| value[:units] == :chart }
      end

      def self.front_end_template_tables
        TEMPLATE_VARIABLES.select {|_key, value| value[:units] == :table }
      end

      def self.front_end_template_variables
        { 'Dummy alert' => TEMPLATE_VARIABLES, 'Common' => {} }
      end

      TEMPLATE_VARIABLES = {
        chart_a: {
          description: 'chart description A',
          units: :chart
        },
        chart_b: {
          description: 'chart description B',
          units: :chart
        },
        table_a: {
          description: 'table description A',
          units: :table
        },
        table_b: {
          description: 'table description B',
          units: :table
        }
      }.freeze
    end
  end
end

FactoryBot.define do
  factory :alert_type do
    sequence(:title)  {|n| "Alert Type #{n}"}
    fuel_type         { :gas }
    sub_category      { :heating }
    frequency         { :weekly }
    class_name        { 'Alerts::System::DummyAlert' }
    description       { title }
    group             { :advice }
  end
end
