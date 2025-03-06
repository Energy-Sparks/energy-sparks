require 'dashboard'

module Solar
  class SolarAreaLookupService
    def initialize(school, school_onboarding = nil)
      @school = school
      @school_onboarding = school_onboarding
    end

    def lookup
      find_nearest_area
    end

    def assign
      solar_area = lookup
      if solar_area
        update_and_load_area(solar_area) unless solar_area.active
        @school.update(solar_pv_tuos_area: solar_area)
      else
        Rollbar.error('No solar area found', scope: :solar_area_lookup_service, school: @school_onboarding.school_name)
      end
      solar_area
    end

    private

    def update_and_load_area(solar_area)
      SolarAreaLoaderJob.perform_later solar_area unless solar_area.solar_pv_tuos_readings.any?
      solar_area.update(active: true)
    end

    def find_nearest_area
      # nearest is last in list
      sorted_list = SolarPvTuosArea.all.sort do |a, b|
        distance_from_school_km(b) <=> distance_from_school_km(a)
      end
      sorted_list.last
    end

    def distance_from_school_km(area)
      LatitudeLongitude.distance(@school.latitude, @school.longitude, area.latitude, area.longitude)
    end
  end
end
