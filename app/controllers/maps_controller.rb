class MapsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @schools = School.visible
    respond_to do |format|
      format.json { render json: encoded_geojson, status: :ok }
      format.html
    end
  end

  private

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

  def point_features
    geo_factory = RGeo::Cartesian.simple_factory
    entity_factory = RGeo::GeoJSON::EntityFactory.instance

    @schools.map do |school|
      if school.latitude && school.longitude
        entity_factory.feature(geo_factory.point(school.longitude, school.latitude), 1, school_details(school))
      end
    end
  end

  def geojson
    entity_factory = RGeo::GeoJSON::EntityFactory.instance
    entity_factory.feature_collection(point_features)
  end

  def encoded_geojson
    RGeo::GeoJSON.encode(geojson)
  end
end
