module Alerts
  module System
    class MissingGasData
      # Temporary constant to match analytics
      TEMPLATE_VARIABLES = {
        mpan_mprns: {
          description: 'A list of the MPAN/MPRNs for the late running meters',
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
        MissingData.new(school: @school, alert_type: @alert_type, today: @today, meter_type: :gas).report
      end
    end
  end
end
