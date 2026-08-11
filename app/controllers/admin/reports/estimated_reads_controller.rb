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
          Column.new(:supplier,
                     ->(meter) { meter.supplier&.name }),
          Column.new(:data_source,
                     ->(meter) { meter.data_source&.name }),
          Column.new(:last_validated_date,
                     ->(meter) { meter.last_validated_reading&.iso8601 }),
          Column.new(:count,
                     ->(meter) { meter.count })
        ]
      end

      def results
        results = Meter.active
                       .joins(:school)
                       .joins(:amr_validated_readings)
                       .where(amr_validated_readings: { status: 'EST' })
                       .includes(:school, { school: :school_group })
                       .group('school_groups.id', 'schools.id', 'meters.id')
                       .select('school_groups.*, meters.*, count(amr_validated_readings.id) as count')

        results = filter_results(results)
        results.order(count: :desc)
      end

      def description
        'Lists all of the meters in the system that have one or more Estimated ("EST") data readings'
      end

      def title
        'Estimated data report'
      end

      def filter_results(results)
        if params[:school_group].present?
          results = results.where(schools: { school_group: SchoolGroup.find(params.expect(:school_group)) })
        end
        if params[:admin].present?
          results = results.where(schools: {
                                    school_groups: {
                                      default_issues_admin_user: User.admin.find(params.expect(:admin))
                                    }
                                  })
        end
        results
      end
    end
  end
end
