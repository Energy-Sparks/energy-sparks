module Admin
  module SchoolGroups
    class MeterReportsController < AdminController
      include ApplicationHelper
      load_and_authorize_resource :school_group

      def show
        @meter_scope = if params.key?(:all_meters)
                         {}
                       else
                         { active: true }
                       end

        respond_to do |format|
          format.html { }
          format.csv { send_data produce_csv(@school_group, @meter_scope), filename: filename(@school_group) }
        end
      end

      private

      def filename(school_group)
        school_group.name.parameterize + '-meter-report.csv'
      end

      def produce_csv(school_group, meter_scope)
        CSV.generate do |csv|
          csv << [
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
          school_group.schools.by_name.each do |school|
            school.meters.where(meter_scope).order(:mpan_mprn).each do |meter|
              csv << [
                school.name,
                meter.meter_type,
                meter.mpan_mprn,
                meter.name,
                meter.data_source.try(:name) || '',
                y_n(meter.active),
                nice_dates(meter.first_validated_reading),
                nice_dates(meter.last_validated_reading),
                date_range_from_reading_gaps(meter.gappy_validated_readings),
                meter.modified_validated_readings.count,
                meter.zero_reading_days.count,
                meter.admin_meter_status_label
              ]
            end
          end
        end
      end
    end
  end
end
