module Maps
  class SchoolFeatures
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

      @schools.each_with_index.map do |school, idx|
        if school.latitude && school.longitude
          entity_factory.feature(geo_factory.point(school.longitude, school.latitude), idx, school_details(school))
        end
      end
    end

    def school_details(school)
      {
        schoolName: school.name,
        schoolType: school.school_type.humanize,
        schoolPath: school_path(school),
        numberOfPupils: school.number_of_pupils,
        fuelTypes: school.fuel_types,
        hasElectricity: school.has_electricity?,
        hasGas: school.has_gas?,
        hasSolarPv: school.has_solar_pv?
      }
    end
  end
end
