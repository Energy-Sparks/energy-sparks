# frozen_string_literal: true

module Admin
  module Reports
    class SolarInstallationsController < BaseImportReportsController
      TYPES = { 'SolarEdge' => SolarEdgeInstallation,
                'Rtone' => LowCarbonHubInstallation,
                'Rtone Variant' => RtoneVariantInstallation,
                'SolisCloud' => SolisCloudInstallation }.freeze

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
        if params[:installation_type].present?
          filtered = filtered.where("#{join_alias(TYPES[params[:installation_type]])}.count > 0")
        end
        filtered
      end

      def results
        filter_results(School.joins(:school_group)
                             .joins(join_count(SolarEdgeInstallation))
                             .joins(join_count(LowCarbonHubInstallation))
                             .joins(join_count(RtoneVariantInstallation))
                             .joins(join_count(solis_cloud_installation))
                             .select('schools.*',
                                     *select_active_inactive(SolarEdgeInstallation),
                                     *select_active_inactive(LowCarbonHubInstallation),
                                     *select_active_inactive(RtoneVariantInstallation),
                                     *select_active_inactive(SolisCloudInstallation))
                             .includes(school_group: %i[default_issues_admin_user]))
      end

      def join_count(model)
        "LEFT JOIN (SELECT COUNT(*),
                           COUNT(*) FILTER (WHERE active) AS active,
                           COUNT(*) FILTER (WHERE active = false) AS inactive,
                           school_id
                    FROM #{model.instance_of?(Class) ? model.table_name : "(#{model.to_sql})"}
                    GROUP BY school_id)
         AS #{join_alias(model)} ON #{join_alias(model)}.school_id = schools.id"
      end

      def solis_cloud_installation
        SolisCloudInstallation.joins(:solis_cloud_installation_schools)
                              .select('solis_cloud_installations.active',
                                      'solis_cloud_installation_schools.school_id')
      end

      def join_alias(model) = "#{model.table_name}_counts"

      def select_active_inactive(model) = %i[active inactive].map { |type| select_type(model, type) }

      def select_type(model, type) = "COALESCE(#{join_alias(model)}.#{type}, 0) AS #{alias_name(model, type)}"

      # def count_subquery(model)
      #   if model.table_name == 'solis_cloud_installations'
      #     "(#{model.joins(:solis_cloud_installation_schools)
      #        .select('COUNT(solis_cloud_installation_schools.*)').to_sql}
      #       AND solis_cloud_installation_schools.school_id = schools.id)"
      #   else
      #     "(#{model.select('COUNT(*)').to_sql} AND #{model.table_name}.school_id = schools.id)"
      #   end
      # end

      # def count_subquery_alias(model, type) = "#{count_subquery(model)} AS #{alias_name(model, type)}"

      def alias_name(model, type) = "#{model.table_name}_#{type}_count"
    end
  end
end
