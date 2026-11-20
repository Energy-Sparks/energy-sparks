# frozen_string_literal: true

module Admin
  module Reports
    # rubocop:disable-next Metrics/ClassLength
    class SolarEdgeController < BaseImportReportsController
      private

      def title = 'Solar Edge Status'

      def description
        'Shows the current configuration status of all SolarEdge sites'
      end

      def columns
        [
          school_group_column,
          admin_column,
          school_column,
          school_active_column,
          contract_column,
          site_id_column,
          consented_column,
          loading_column,
          solar_edge_status_column,
          metered_solar_column,
          meter_status_column(:solar_meter_active?, :solar_pv),
          meter_status_column(:export_meter_active?, :exported_solar_pv),
          meter_status_column(:electricity_meter_active?, :electricity),
          credit_estimate_column,
          issue_column,
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

      def school_column
        Column.new(:school,
                   ->(installation) { installation.school.name },
                   ->(installation, csv) { link_to(csv, school_path(installation.school)) })
      end

      def consented_column
        BoolColumn.new(:consented?, ->(installation) { installation.consented? })
      end

      def loading_column
        BoolColumn.new(:loading_enabled?, ->(installation) { installation.active })
      end

      def school_active_column
        BoolColumn.new(:school_active?, ->(installation) { installation.school.active })
      end

      def contract_column
        Column.new(:contract, ->(installation) { installation.school.current_contract })
      end

      def site_id_column
        Column.new(:site, ->(installation) { installation.site_id })
      end

      def solar_edge_status_column
        BoolColumn.new(:monitoring_active?, ->(installation) { installation.monitoring_active? })
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
        Column.new(:daily_credit_estimate, ->(installation) { installation.credit_estimate })
      end

      def issue_column
        issue_tag = IssueTag.find_by(system_id: :solar_setup)
        Column.new(:'issues_&_notes',
                   nil,
                   lambda { |installation|
                     render_to_string(partial: 'issues',
                                      locals: { school: installation.school, issue_tag: })
                   },
                   display: :html)
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
        filter_results(
          SolarEdgeInstallation.joins(:school, school: :school_group)
                              .left_outer_joins(school: :licences)
                              .includes(:school, school: :school_group)
        )
      end

      def filter_by_school_status(results)
        apply_filter(results, :school_active) do |results, school_active|
          results.where(schools: { active: school_active })
        end
      end

      def filter_by_contract(results)
        apply_filter(results, :contract_id) do |results, contract_id|
          results.where(schools: { commercial_licences: { contract_id: contract_id } })
        end
      end

      def filter_results(results)
        results = filter_by_admin(results)
        results = filter_by_school_group(results)
        results = filter_by_school_status(results)
        results = filter_by_contract(results)
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
