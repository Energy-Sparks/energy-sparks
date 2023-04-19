module Admin
  module SchoolGroups
    class MeterReportsController < AdminController
      include ApplicationHelper
      load_and_authorize_resource :school_group
      before_action :meter_scope

      def show
        @meter_scope = params.key?(:all_meters) ? {} : { active: true }
        respond_to do |format|
          format.html { }
          format.csv do
            send_data csv.content,
            filename: csv.filename
            #format.html { @meters = meters(@school_group, @meter_scope) }
            #format.csv { send_data produce_csv(@school_group, @meter_scope), filename: filename(@school_group) }
        end
      end

      private

      def meters(school_group, meter_scope)
        Meter.where(meter_scope)
          .joins(:school)
          .joins(:school_group)
          .where(schools: { school_group: school_group })
          .with_counts
          .order("schools.name", :mpan_mprn)
      end

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
          meters(school_group, meter_scope).each do |meter|
              csv << [
                meter.school.name,
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

      def deliver
        AdminMailer.with(to: current_user.email, school_group: @school_group, filename: csv.filename, csv: csv.content).school_group_meters_report.deliver
        redirect_to admin_school_group_path(@school_group), notice: "Report requested to be sent to #{current_user.email}"
      end

      private

      def csv
        @csv ||= ::SchoolGroups::Meters::CsvGenerator.new(@school_group, @meter_scope)
      end

      def meter_scope
        @meter_scope = params.key?(:all_meters) ? {} : { active: true }
      end
    end
  end
end
