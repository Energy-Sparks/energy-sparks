module SchoolAggregation
  extend ActiveSupport::Concern

private

  def aggregate_school_service(school)
    @aggregate_school_service ||= AggregateSchoolService.new(school)
  end

  def aggregate_school(school)
    aggregate_school_service(school).aggregate_school
  end
end
