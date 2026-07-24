# frozen_string_literal: true

module Admin
  module Reports
    class SolarInstallationsController < BaseImportReportsController
      TYPES = { 'SolarEdge' => SolarEdgeInstallation,
                'Rtone' => LowCarbonHubInstallation,
                'Rtone Variant' => RtoneVariantInstallation,
                'SolisCloud' => SolisCloudInstallation,
                'MeterZ' => MeterZInstallation }.freeze

      private

      def title = 'Solar Installations'

      def columns
        [school_group_column,
         Column.new(:admin, ->(school) { school.default_issues_admin_user&.name }),
         Column.new(:school, ->(school) { school.name }, ->(school, csv) { link_to(csv, school_path(school)) }),
         *count_columns,
         action_column]
      end

      def school_group_column
        Column.new(:school_group,
                   ->(school) { school.school_group&.name },
                   ->(school, csv) { csv && link_to(csv, school_group_path(school.school_group)) })
      end

      def count_columns
        TYPES.flat_map do |name, model|
          [Column.new("#{name} Active", ->(school) { school.public_send(alias_name(model, :active)) }),
           Column.new("#{name} Inactive", ->(school) { school.public_send(alias_name(model, :inactive)) })]
        end
      end

      def action_column
        Column.new('', nil,
                   lambda { |school|
                     link_to('Solar Feeds', school_solar_feeds_configuration_index_path(school),
                             class: 'btn btn-sm btn-secondary')
                   },
                   display: :html, html_data: { sortable: false })
      end

      def filter_results(results)
        filtered = super
        if params[:installation_type].present? && TYPES.key?(params[:installation_type])
          filtered = filtered.where(where_solar_installation(TYPES[params[:installation_type]]))
        end
        filtered
      end

      def where_solar_installation(model) = "#{join_alias(model)}.total > 0"

      def results
        filter_results(School.joins(:school_group)
                             .joins(join_count(SolarEdgeInstallation))
                             .joins(join_count(LowCarbonHubInstallation))
                             .joins(join_count(RtoneVariantInstallation))
                             .joins(join_count(solis_cloud_installation))
                             .joins(join_count(meter_z_installation))
                             .select('schools.*', *select_active_inactive)
                             .where(where_any_solar_installations)
                             .includes(school_group: %i[default_issues_admin_user]))
      end

      def join_count(model)
        "LEFT JOIN (SELECT COUNT(*) AS total,
                           COUNT(*) FILTER (WHERE active) AS active,
                           COUNT(*) FILTER (WHERE NOT active) AS inactive,
                           school_id
                    FROM #{model.instance_of?(Class) ? model.table_name : "(#{model.to_sql}) AS installations"}
                    GROUP BY school_id)
         AS #{join_alias(model)} ON #{join_alias(model)}.school_id = schools.id"
      end

      def solis_cloud_installation
        SolisCloudInstallation.joins(:solis_cloud_installation_schools)
                              .select('solis_cloud_installations.active', 'solis_cloud_installation_schools.school_id')
      end

      def meter_z_installation
        MeterZInstallation.joins(:meters)
                          .select('meter_z_installations.active', 'meters.school_id')
      end

      def join_alias(model) = "#{model.table_name}_counts"

      def select_active_inactive
        TYPES.values.product(%i[active inactive]).map { |model, type| select_type(model, type) }
      end

      def select_type(model, type) = "COALESCE(#{join_alias(model)}.#{type}, 0) AS #{alias_name(model, type)}"

      def where_any_solar_installations = TYPES.values.map { |model| where_solar_installation(model) }.join(' OR ')

      def alias_name(model, type) = "#{model.table_name}_#{type}_count"
    end
  end
end
