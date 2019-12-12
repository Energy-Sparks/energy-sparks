require 'dashboard'

module Amr
  class AnalyticsSchoolFactory
    def initialize(active_record_school)
      @active_record_school = active_record_school
    end

    def build
      {
        name: @active_record_school.name,
        address: @active_record_school.address,
        floor_area: floor_area,
        number_of_pupils: @active_record_school.number_of_pupils,
        school_type: @active_record_school.school_type,
        area_name: @active_record_school.area_name,
        urn: @active_record_school.urn,
        postcode: @active_record_school.postcode
      }
    end

  private

    def floor_area
      @active_record_school.floor_area.to_f
    end
  end
end
