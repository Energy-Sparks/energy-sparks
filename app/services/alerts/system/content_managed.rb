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

      def initialize(school:, today: Time.zone.today)
        @school = school
        @today = today
      end

      def report
        Adapters::Report.new(
          valid: true,
          status: :good,
          rating: 10.0,
          enough_data: :enough,
          template_data: {
            school_name: @school.name
          }
        )
      end
    end
  end
end
