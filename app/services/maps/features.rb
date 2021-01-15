module Maps
  class Features
    include Rails.application.routes.url_helpers

    def initialize(schools)
      @schools = schools
    end

    def as_json
      RGeo::GeoJSON.encode(geojson)
    end

    private

    def geojson
      entity_factory = RGeo::GeoJSON::EntityFactory.instance
      entity_factory.feature_collection(point_features)
    end

    def point_features
      geo_factory = RGeo::Cartesian.simple_factory
      entity_factory = RGeo::GeoJSON::EntityFactory.instance

      @schools.map do |school|
        if school.latitude && school.longitude
          entity_factory.feature(geo_factory.point(school.longitude, school.latitude), 1, school_details(school))
        end
      end
    end

    def school_details(school)
      {
        schoolName: school.name,
        schoolType: school.school_type.humanize,
        schoolPath: school_path(school),
        number_of_pupils: school.number_of_pupils,
        fuel_types: school.fuel_types,
        has_electricity: school.has_electricity?,
        has_gas: school.has_gas?,
        has_solar_pv: school.has_solar_pv?
      }
    end
  end
end
