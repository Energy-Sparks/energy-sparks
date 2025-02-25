# frozen_string_literal: true

module Admin
  module Reports
    class ManualReadsController < AdminController
      include Columns
      include ActionView::Helpers::UrlHelper
      include ApplicationHelper

      def index
        columns = [
          Column.new(:group_name,
                     ->(meter) { meter.school.school_group&.name },
                     ->(meter, csv) { csv && link_to(csv, school_group_url(meter.school.school_group)) }),
          Column.new(:school_name,
                     ->(meter) { meter.school.name },
                     ->(meter, csv) { link_to(csv, school_url(meter.school)) }),
          Column.new(:group_owner,
                     ->(meter) { meter.school.school_group&.default_issues_admin_user&.name }),
          Column.new(:MPAN,
                     ->(meter) { meter.mpan_mprn },
                     ->(meter, csv) { link_to(csv, school_meter_url(meter.school, meter)) }),
          Column.new(:meter_type,
                     ->(meter) { meter.meter_type.to_s }),
          Column.new(:data_source,
                     ->(meter) { meter.data_source&.name }),
          Column.new(:last_validated_date,
                     ->(meter) { meter.last_validated_reading&.strftime('%d/%m/%Y') },
                     ->(meter) { nice_dates(meter.last_validated_reading) }),
          Column.new(:'issues_&_notes',
                     nil,
                     ->(meter) { render_to_string(partial: 'admin/issues/modal', locals: { meter: }) },
                     display: :html),
          Column.new(:issues,
                     ->(meter) { meter.issues.issue.count },
                     display: :csv),
          Column.new(:notes,
                     ->(meter) { meter.issues.note.count },
                     display: :csv)
        ]
        @html_columns = columns.filter(&:display_html)
        @meters = Meter.active.where(manual_reads: true)
        respond_to do |format|
          format.html
          format.csv do
            send_data csv_report(columns), filename: EnergySparks::Filenames.csv('manual-reads-report')
          end
        end
      end
    end
  end
end
