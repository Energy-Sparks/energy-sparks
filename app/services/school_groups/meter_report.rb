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
          'Data source',
          'Procurement route',
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

    attr_reader :school_group, :full_detail, :all_meters

    def initialize(school_group, full_detail: true, all_meters: false)
      @school_group = school_group
      @full_detail = full_detail
      @all_meters = all_meters
    end

    def csv_filename
      "#{school_group.name}-meter-report".parameterize + '.csv'
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
            meter.data_source.try(:name) || '',
            meter.procurement_route.try(:organisation_name) || '',
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

    def meters
      @meters ||= meter_scope
    end

    private

    def meter_scope
      scope = Meter.all
        .joins(:school)
        .joins(:school_group)
        .where(schools: { school_group: school_group })
        .order("schools.name", :mpan_mprn)
      scope = full_detail ? scope.with_counts : scope.with_reading_dates
      scope = all_meters ? scope : scope.active
      scope
    end
  end
end
