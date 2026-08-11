# frozen_string_literal: true

module Admin
  module Reports
    class EstimatedReadsController < Admin::Reports::BaseMeterReportsController
      private

      def columns
        super + extra_columns
      end

      def extra_columns # rubocop:disable Metrics/AbcSize
        [
          Column.new(:meter_type,
                     ->(meter) { meter.meter_type.to_s },
                     lambda { |meter|
                       render_to_string(Elements::IconComponent.new(fuel_type: meter.meter_type), layout: false)
                     }),
          Column.new(:meter_system,
                     ->(meter) { meter.t_meter_system }),
          Column.new(:supplier,
                     ->(meter) { meter.supplier&.name }),
          Column.new(:data_source,
                     ->(meter) { meter.data_source&.name }),
          Column.new(:admin_meter_status,
                     ->(meter) { meter.admin_meter_status_label }),
          Column.new(:last_validated_date,
                     ->(meter) { meter.last_validated_reading&.iso8601 }),
          Column.new(:total,
                     ->(meter) { meter.total }),
          Column.new(:recent,
                     ->(meter) { meter.recent })
        ]
      end

      def results
        30.days.ago

        results = Meter.active
                       .joins(:school)
                       .joins(:amr_validated_readings)
                       .where(amr_validated_readings: { status: 'EST' })
                       .includes(:school, { school: :school_group })
                       .group('school_groups.id', 'schools.id', 'meters.id')
                       .select(
                         'school_groups.*',
                         'meters.*',
                         'COUNT(amr_validated_readings.id) AS total',
                         <<~SQL.squish
                           SUM(
                             CASE
                               WHEN amr_validated_readings.reading_date > (
                                 (
                                   SELECT MAX(avr2.reading_date)
                                   FROM amr_validated_readings AS avr2
                                   WHERE avr2.meter_id = meters.id
                                 ) - INTERVAL '30 days'
                               )
                               THEN 1 ELSE 0
                             END
                           ) AS recent
                         SQL
                       )

        results = filter_results(results)
        results.order(count: :desc)
      end

      def description
        'Lists all of active meters in the system that have one or more Estimated ("EST") data readings'
      end

      def title
        'Estimated data report'
      end

      def filter_results(results)
        results = filter_by_meter_type(results)
        results = filter_by_group(results)
        filter_by_admin(results)
      end

      def filter_by_meter_type(results)
        results = results.where(meter_type: params[:meter_type]) if params[:meter_type].present?
        results
      end

      def filter_by_group(results)
        if params[:school_group].present?
          results = results.where(schools: { school_group: SchoolGroup.find(params.expect(:school_group)) })
        end
        results
      end

      def filter_by_admin(results)
        if params[:admin].present?
          results = results.where(schools: {
                                    school_groups: {
                                      default_issues_admin_user: User.admin.find(params.expect(:admin))
                                    }
                                  })
        end
        results
      end

      def container_class
        'container-fluid'
      end
    end
  end
end
