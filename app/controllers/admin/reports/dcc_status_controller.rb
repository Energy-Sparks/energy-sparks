module Admin
  module Reports
    class DccStatusController < AdminController
      include Columns
      include ActionView::Helpers::UrlHelper
      include ApplicationHelper

      before_action :set_consented_mpxns

      def index
        meter_issue_counts =
          Meter.joins(:issues).where(issues: { status: :open }).group('meters.id', 'issues.issue_type')
               .count
               .each_with_object(Hash.new do |hash, meter_id|
                                   hash[meter_id] =
                                     ActiveSupport::OrderedOptions.new.merge(id: meter_id, issues: Hash.new(0))
                                 end) do |(k, v), h|
            meter_id, issue_type = k
            h[meter_id].issues[issue_type] = v
          end
        @columns = [
          Column.new(:school_name,
                     ->(meter) { meter.school.name },
                     ->(meter, csv) { link_to(csv, school_meters_path(meter.school)) }),
          Column.new(:group_name,
                     ->(meter) { meter.school.school_group&.name },
                     ->(meter, csv) { csv && link_to(csv, school_group_path(meter.school.school_group)) }),
          Column.new(:school_archived?,
                     ->(meter) { y_n(meter.school.archived?) }),
          Column.new(:group_owner,
                     ->(meter) { meter.school.school_group&.default_issues_admin_user&.name }),
          Column.new(:type,
                     ->(meter) { meter.meter_type.to_s.titleize },
                     ->(meter) { fa_icon(fuel_type_icon(meter.meter_type)) }),
          Column.new(:data_source,
                     ->(meter) { meter.data_source&.name }),
          Column.new(:MPAN,
                     ->(meter) { meter.mpan_mprn }),
          Column.new(:meter_name,
                     ->(meter) { meter.name_or_mpan_mprn },
                     ->(meter, csv) { link_to(csv, school_meter_path(meter.school, meter)) }),
          Column.new(:active?,
                     ->(meter) { y_n(meter.active) }),
          Column.new(:consented?,
                     ->(meter) { y_n(meter.consent_granted) }),
          Column.new(:earliest_validated,
                     ->(meter) { meter.min }),
          Column.new(:latest_validated,
                     ->(meter) { meter.max }),
          Column.new(:issues,
                     ->(meter) { meter.issues.issue.count },
                     lambda { |meter|
                       render_to_string(partial: 'admin/issues/modal', locals: { meter: meter_issue_counts[meter.id] })
                     },
                     html_data: { sortable: false })
        ]
        @dcc_meters = Meter.admin_report(Meter.dcc)
        @schools_count = Meter.dcc.distinct.count(:school_id)
        respond_to do |format|
          format.html
          format.csv do
            send_data(csv_report(@columns, @dcc_meters.order('schools.name')),
                      filename: EnergySparks::Filenames.csv('dcc-status-report'))
          end
        end
      end

      private

      def set_consented_mpxns
        @mpxns = Meters::N3rgyMeteringService.consented_meters
        @consent_lookup_error = false
      rescue StandardError
        @mpxns = []
        @consent_lookup_error = true
      end
    end
  end
end
