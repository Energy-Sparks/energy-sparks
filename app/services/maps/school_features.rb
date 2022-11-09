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

    def fuel_type_icons_html_for(school)
      fuel_type_icons = ''
      fuel_type_icons += "&nbsp;<i class='fas fa-bolt'></i>" if school.has_electricity?
      fuel_type_icons += "&nbsp;<i class='fas fa-fire'></i>" if school.has_gas?
      fuel_type_icons += "&nbsp;<i class='fas fa-sun'></i>" if school.has_solar_pv?
      fuel_type_icons
    end

    def build_popup_html_for(school)
      <<-HTML
        <a href='#{school_path(school)}'>#{school.name}</a>
        <br/>
        <p>#{I18n.t('maps.school_features.school_type')}: #{school.school_type.humanize}</p>
        <p>#{I18n.t('maps.school_features.fuel_types')}: #{fuel_type_icons_html_for(school)}</p>
        <p>#{I18n.t('maps.school_features.pupils')}: #{school.number_of_pupils}</p>
      HTML
    end

    def school_details(school)
      school_popup_html = ActionController::Base.helpers.sanitize(build_popup_html_for(school))
      { schoolPopupHtml: school_popup_html }
    end
  end
end
