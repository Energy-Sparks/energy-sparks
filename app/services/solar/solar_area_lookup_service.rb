require 'dashboard'

module Solar
  class SolarAreaLookupService
    def initialize(school)
      @school = school
    end

    def lookup(scope: SolarPvTuosArea.assignable)
      # nearest is last in list
      sorted_list = scope.sort do |a, b|
        distance_from_school_km(b) <=> distance_from_school_km(a)
      end
      sorted_list.last
    end

    def assign(scope: SolarPvTuosArea.assignable, trigger_load: true)
      solar_area = lookup(scope: scope)
      if solar_area
        @school.update(solar_pv_tuos_area: solar_area)
        solar_area.update(active: true)
        load_area(solar_area) if trigger_load
      else
        Rollbar.error('No solar area found', scope: :solar_area_lookup_service, school: @school.name)
      end
      solar_area
    end

    private

    def load_area(solar_area)
      SolarAreaLoaderJob.perform_later solar_area unless solar_area.solar_pv_tuos_readings.any?
    end

    def distance_from_school_km(area)
      LatitudeLongitude.distance(@school.latitude, @school.longitude, area.latitude, area.longitude)
    end
  end
end
