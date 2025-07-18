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

      @schools.map do |school|
        if school.latitude && school.longitude
          entity_factory.feature(geo_factory.point(school.longitude, school.latitude), school.id)
        end
      end
    end
  end
end
