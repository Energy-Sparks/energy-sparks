require 'dashboard'

module Amr
  class AnalyticsSchoolFactory
    def initialize(active_record_school)
      @active_record_school = active_record_school
    end

    def build
      {
        id: @active_record_school.id,
        name: @active_record_school.name,
        address: @active_record_school.address,
        floor_area: floor_area,
        number_of_pupils: @active_record_school.number_of_pupils,
        school_type: @active_record_school.school_type,
        area_name: @active_record_school.area_name,
        urn: @active_record_school.urn,
        postcode: @active_record_school.postcode,
        country: country,
        funding_status: funding_status,
        activation_date: @active_record_school.activation_date,
        created_at: @active_record_school.created_at,
        school_times: @active_record_school.school_times_to_analytics,
        community_use_times: @active_record_school.community_use_times_to_analytics,
        location: location,
        data_enabled: @active_record_school.data_enabled
      }
    end

    private

    def country
      @active_record_school.country ? @active_record_school.country.to_sym : :england
    end

    def funding_status
      case @active_record_school.funding_status
      when 'private_school'
        :private
      else
        :state
      end
    end

    def location
      [@active_record_school.latitude, @active_record_school.longitude]
    end

    def floor_area
      @active_record_school.floor_area.to_f
    end
  end
end
