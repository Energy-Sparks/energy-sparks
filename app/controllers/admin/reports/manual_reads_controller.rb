# frozen_string_literal: true

module Admin
  module Reports
    class ManualReadsController < AdminController
      include ActionView::Helpers::UrlHelper
      include ApplicationHelper

      class Column
        def initialize(name, csv_lambda, td_lambda = nil, display: :csv_and_html)
          @name = name
          @csv_lambda = csv_lambda
          @td_lambda = td_lambda
          @display = display
        end

        def name
          string = @name.to_s
          string.downcase == string ? string.titleize : string
        end

        def csv(arg)
          @csv_lambda.call(arg)
        end

        def td(arg)
          if @td_lambda&.arity == 2
            @td_lambda.call(arg, csv(arg))
          else
            (@td_lambda || @csv_lambda).call(arg)
          end
        end

        def display_html
          %i[csv_and_html html].include?(@display)
        end

        def display_csv
          %i[csv_and_html csv].include?(@display)
        end
      end

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

      def csv_report(columns)
        csv_columns = columns.filter(&:display_csv)
        CSV.generate(headers: true) do |csv|
          csv << csv_columns.map(&:name)
          @meters.find_each do |meter|
            csv << csv_columns.map { |column| column.csv(meter) }
          end
        end
      end
    end
  end
end
