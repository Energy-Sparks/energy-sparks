# frozen_string_literal: true

module Admin
  module Reports
    class SolarEdgeController < BaseImportReportsController
      private

      def title = 'Solar Edge Status'

      def columns
        [
          school_group_column,
          school_column,
          admin_column,
          site_id_column,
          BoolColumn.new(:consented?, ->(installation) { installation.consented? }),
          BoolColumn.new(:loading_enabled?, ->(installation) { installation.active }),
          metered_solar_column,
          meter_status_column(:solar_meter_active?, :solar_pv),
          meter_status_column(:export_meter_active?, :exported_solar_pv),
          meter_status_column(:electricity_meter_active?, :electricity),
          credit_estimate_column,
          action_column
        ]
      end

      def school_group_column
        Column.new(:school_group,
                   ->(installation) { installation.school.school_group&.name },
                   lambda { |installation, csv|
                     csv && link_to(csv, school_group_path(installation.school.school_group))
                   })
      end

      def admin_column
        Column.new(:admin, ->(installation) { installation.school.default_issues_admin_user&.name })
      end

      def site_id_column
        Column.new(:site, ->(installation) { installation.site_id })
      end

      def school_column
        Column.new(:school,
                   ->(installation) { installation.school.name },
                   ->(installation, csv) { link_to(csv, school_path(installation.school)) })
      end

      def meter_status_column(name, meter_type)
        BoolColumn.new(name,
                       ->(installation) { installation.meters.where(meter_type:).any?(&:active) })
      end

      def metered_solar_column
        BoolColumn.new(:metered_solar_configured?,
                       lambda do |installation|
                         return false unless installation.meters.solar_pv.any?

                         installation.school.meters.electricity.active
                           .with_active_meter_attributes(%w[solar_pv_mpan_meter_mapping])
                           .where(
                             'meter_attributes.input_data::text LIKE ?',
                             "%#{installation.meters.solar_pv.first.mpan_mprn}%"
                           ).any?
                       end)
      end

      def credit_estimate_column
        Column.new(:daily_credit_estimate,
                   lambda do |installation|
                     return 0 unless installation.active && installation.consented?

                     2 + (2 * installation.meters.active.count)
                   end)
      end

      def action_column
        Column.new('', nil,
                   lambda { |installation|
                     link_to('Solar Feeds', school_solar_feeds_configuration_index_path(installation.school),
                             class: 'btn btn-sm btn-secondary')
                   },
                   display: :html, html_data: { sortable: false })
      end

      def results
        filter_results(SolarEdgeInstallation.joins(:school, school: :school_group))
      end

      def filter_results(results)
        results = filter_by_admin(results)
        results = filter_by_school_group(results)
        case params[:consented]
        when 'true'
          results = results.where.not(consent_granted_at: nil)
        when 'false'
          results = results.where(consent_granted_at: nil)
        end
        results
      end
    end
  end
end
