module Admin
  class SchoolManagementsController < AdminController
    include SchoolAggregation

    def show
      @school = School.find(params[:school_id])
      @meter_collection = AggregateSchoolService.new(@school).aggregate_school
    end
  end
end
