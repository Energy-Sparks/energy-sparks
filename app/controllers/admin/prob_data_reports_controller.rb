module Admin
  class ProbDataReportsController < Admin::Reports::BaseMeterReportsController
    private

    def columns
      super + [
        Column.new(:meter_type,
                   ->(meter) { meter.meter_type.to_s },
                   ->(meter) { render_to_string(IconComponent.new(fuel_type: meter.meter_type), layout: false) }),
        Column.new(:count,
                   ->(meter) { meter.count })
      ]
    end

    def results
      results = Meter.active
           .joins(:school)
           .joins(:amr_validated_readings)
           .where(amr_validated_readings: { status: 'PROB' })
           .includes(:school, { school: :school_group })
           .group('school_groups.id', 'schools.id', 'meters.id')
           .select('school_groups.*, meters.*, count(amr_validated_readings.id) as count')

      results = results.where(schools: { school_group: SchoolGroup.find(params[:school_group]) }) if params[:school_group].present?
      results = results.where(schools: { school_groups: { default_issues_admin_user: User.admin.find(params[:user]) } }) if params[:user].present?
      results.order('count DESC')
    end

    def description
      'Lists all of the meters in the system that have one or more "PROB" data readings'
    end

    def title
      'PROB data report'
    end
  end
end
