# frozen_string_literal: true

module Admin
  module Reports
    class SolarInstallationsController < BaseMeterReportsController
      private

      def title = 'Solar Installations'

      def columns
        [school_group_column,
         Column.new(:admin, ->(school) { school.default_issues_admin_user&.name }),
         Column.new(:school,
                    ->(school) { school.name },
                    ->(school, csv) { link_to(csv, school_path(school)) })] + count_columns
      end

      def count_columns
        [Column.new('SolarEdge Active', ->(school) { school.solar_edge_installations_active_count }),
         Column.new('SolarEdge Inactive', ->(school) { school.solar_edge_installations_inactive_count }),
         Column.new('SolisCloud Active', ->(school) { school.solis_cloud_installations_active_count }),
         Column.new('SolisCloud Inactive', ->(school) { school.solis_cloud_installations_inactive_count }),
         Column.new('Rtone Active', ->(school) { school.low_carbon_hub_installations_active_count }),
         Column.new('Rtone Inactive', ->(school) { school.low_carbon_hub_installations_inactive_count }),
         Column.new('Rtone Variant Active', ->(school) { school.rtone_variant_installations_active_count }),
         Column.new('Rtone Variant Inactive', ->(school) { school.rtone_variant_installations_inactive_count })]
      end

      def school_group_column
        Column.new(:school_group,
                   ->(school) { school.school_group&.name },
                   ->(school, csv) { csv && link_to(csv, school_group_path(school.school_group)) })
      end

      def results
        School.select(
          'schools.*',
          count_subquery(SolarEdgeInstallation.active, :active),
          count_subquery(SolarEdgeInstallation.active.invert_where, :inactive),
          count_solis_cloud(SolisCloudInstallation.active, :active),
          count_solis_cloud(SolisCloudInstallation.active.invert_where, :inactive),
          count_subquery(LowCarbonHubInstallation.active, :active),
          count_subquery(LowCarbonHubInstallation.active.invert_where, :inactive),
          count_subquery(RtoneVariantInstallation.active, :active),
          count_subquery(RtoneVariantInstallation.active.invert_where, :inactive)
        ).includes(school_group: %i[default_issues_admin_user])
      end

      def count_subquery(model, type)
        "(#{model.select('COUNT(*)').to_sql} AND #{model.table_name}.school_id = schools.id)" \
          "AS #{model.table_name}_#{type}_count"
      end

      def count_solis_cloud(model, type)
        "(#{model.joins(:solis_cloud_installation_schools).select('COUNT(solis_cloud_installation_schools.*)').to_sql}
          AND solis_cloud_installation_schools.school_id = schools.id) AS #{model.table_name}_#{type}_count"
      end
    end
  end
end
