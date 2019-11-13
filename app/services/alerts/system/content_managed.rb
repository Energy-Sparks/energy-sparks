module Alerts
  module System
    class ContentManaged
      # Temporary constant to match analytics
      TEMPLATE_VARIABLES = {
        school_name: {
          description: 'The name of the school viewing the content',
          units: :string
        }
      }.freeze

      def self.front_end_template_variables
        {
          'General' => TEMPLATE_VARIABLES
        }
      end

      def self.front_end_template_charts
        {}
      end

      def self.front_end_template_tables
        {}
      end

      def self.benchmark_template_variables
        {}
      end

      def initialize(school:, alert_type:, today: Time.zone.today)
        @school = school
        @today = today
        @alert_type = alert_type
      end

      def report
        Adapters::Report.new(
          valid: true,
          rating: 5.0,
          enough_data: :enough,
          relevance: :relevant,
          asof_date: @today,
          alert_type: @alert_type,
          template_data: {
            school_name: @school.name
          }
        )
      end
    end
  end
end
