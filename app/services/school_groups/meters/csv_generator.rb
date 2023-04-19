module SchoolGroups
  module Meters
    class CsvGenerator
      include ApplicationHelper
      class << self
        def csv_headers
          [
            'School',
            'Supply',
            'Number',
            'Meter',
            'Data source',
            'Active',
            'First validated reading',
            'Last validated reading',
            'Large gaps (last 2 years)',
            'Modified readings (last 2 years)',
            'Zero reading days',
            'Admin meter status'
          ]
        end
      end

      def initialize(school_group, meter_scope = {})
        @school_group = school_group
        @meter_scope = meter_scope
      end

      def filename
        "#{@school_group.name}-meter-report".parameterize + '.csv'
      end

      def content
        CSV.generate(headers: true) do |csv|
          csv << self.class.csv_headers
          @school_group.schools.by_name.each do |school|
            school.meters.where(@meter_scope)
              .with_counts
              .order(:mpan_mprn).each do |meter|
              csv << [
                school.name,
                meter.meter_type,
                meter.mpan_mprn,
                meter.name,
                meter.data_source.try(:name) || '',
                y_n(meter.active),
                nice_dates(meter.first_validated_reading_date),
                nice_dates(meter.last_validated_reading_date),
                date_range_from_reading_gaps(meter.gappy_validated_readings),
                meter.modified_validated_readings.count,
                meter.zero_reading_days_count,
                meter.admin_meter_status_label
              ]
            end
          end
        end
      end
    end
  end
end
