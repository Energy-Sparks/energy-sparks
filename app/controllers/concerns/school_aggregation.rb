module SchoolAggregation
  extend ActiveSupport::Concern

private

  def aggregate_school(school)
    AggregateSchoolService.new(school).aggregate_school
  end
end
