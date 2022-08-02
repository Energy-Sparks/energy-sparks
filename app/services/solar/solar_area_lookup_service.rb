require 'dashboard'

module Solar
  class SolarAreaLookupService
    def initialize(school, school_onboarding = nil)
      @school = school
      @school_onboarding = school_onboarding
    end

    def lookup
      if EnergySparks::FeatureFlags.active?(:auto_assign_solar_area)
        find_nearest_area
      else
        #original behaviour was to use area assigned from the onboarding
        @school_onboarding.present? ? @school_onboarding.solar_pv_tuos_area : nil
      end
    end

    def assign
      solar_area = lookup
      if solar_area
        solar_area.update(active: true) unless solar_area.active
        @school.update(solar_pv_tuos_area: solar_area)
      else
        Rollbar.error('No solar area found', scope: :solar_area_lookup_service, school: @school_onboarding.school_name)
      end
      solar_area
    end

    private

    def find_nearest_area
      #nearest is last in list
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
