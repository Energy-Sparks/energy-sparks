require 'dashboard'

module Amr
  class AnalyticsSchoolFactory
    def initialize(active_record_school, school_class = Dashboard::School)
      @active_record_school = active_record_school
      @school_class = school_class
    end

    def build
      @school_class.new(
        @active_record_school.name,
        @active_record_school.address,
        floor_area,
        @active_record_school.number_of_pupils,
        @active_record_school.school_type,
        @active_record_school.area_name,
        @active_record_school.urn,
        @active_record_school.postcode
      )
    end

  private
    def floor_area
      @active_record_school.floor_area.to_f
    end
  end
end
