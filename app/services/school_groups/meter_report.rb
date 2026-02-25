module SchoolGroups
  class MeterReport
    include ApplicationHelper

    class << self
      def csv_headers
        [
          'School',
          'Supply',
          'Number',
          'Meter',
          'Half-Hourly',
          'Data source',
          'Admin meter status',
          'Procurement route',
          'Active',
          'First validated reading',
          'Last validated reading',
          'Large gaps (last 2 years)',
          'Modified readings (last 2 years)',
          'Zero reading days'
        ]
      end
    end

    attr_reader :school_group, :all_meters

    def initialize(school_group, all_meters: false)
      @school_group = school_group
      @all_meters = all_meters
    end

    def csv_filename
      filename = "#{school_group.name}-meter-report-#{Time.zone.now.iso8601}"
      filename += '-all-meters' if all_meters
      filename.parameterize + '.csv'
    end

    def csv
      CSV.generate(headers: true) do |csv|
        csv << self.class.csv_headers
        meters.each do |meter|
          csv << [
            meter.school.name,
            meter.meter_type,
            meter.mpan_mprn,
            meter.name,
            meter.t_meter_system,
            meter.data_source.try(:name) || '',
            meter.admin_meter_status_label,
            meter.procurement_route.try(:organisation_name) || '',
            y_n(meter.active),
            meter.first_validated_reading_date&.to_fs(:es_compact),
            meter.last_validated_reading_date&.to_fs(:es_compact),
            date_range_from_reading_gaps(meter.gappy_validated_readings),
            meter.modified_validated_readings.count,
            meter.zero_reading_days_count
          ]
        end
      end
    end

    def meters
      @meters ||= meter_scope
    end

    private

    def meter_scope
      scope = Meter.all
        .joins(:school, school: :school_groupings)
        .where(schools: { active: true, school_groupings: { school_group: school_group } })
        .with_zero_reading_days_and_dates
        .order('schools.name', :mpan_mprn)
      scope = all_meters ? scope : scope.active
      scope
    end
  end
end
