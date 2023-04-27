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

    def initialize(school_group, meter_scope = {})
      @school_group = school_group
      @meter_scope = meter_scope
    end

    def csv_filename
      "#{@school_group.name}-meter-report".parameterize + '.csv'
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

    def meters(full_detail: true)
      if full_detail
        Meter.where(@meter_scope)
          .joins(:school)
          .joins(:school_group)
          .where(schools: { school_group: @school_group })
          .with_counts
          .order("schools.name", :mpan_mprn)
      else
        Meter.where(@meter_scope)
          .joins(:school)
          .joins(:school_group)
          .where(schools: { school_group: @school_group })
          .with_reading_dates
          .order("schools.name", :mpan_mprn)
      end
    end
  end
end
