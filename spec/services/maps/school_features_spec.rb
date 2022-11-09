require 'rails_helper'

describe Maps::SchoolFeatures do

  #
  # Format of JSON for features looks like this:
  #
  # {
  #   "type"=>"FeatureCollection",
  #   "features"=> [
  #     {
  #       "type"=>"Feature",
  #       "geometry"=> {
  #         "type"=>"Point",
  #         "coordinates"=> [school.longitude, school.latitude]
  #       },
  #       "properties"=>{
  #         "schoolName"=>school.name
  #       },
  #       "id"=>1
  #     }
  #   ]
  # }


  let!(:school_1)             { create(:school, name: 'My School 1', number_of_pupils: 100)}
  let!(:school_2)             { create(:school, name: 'My School 2', number_of_pupils: 200)}
  let!(:school_3)             { create(:school, name: 'My School 3', number_of_pupils: 300)}

  let!(:fuel_electricity)     { Schools::FuelConfiguration.new(has_electricity: true) }
  let!(:school_1_config)      { create(:configuration, school: school_1, fuel_configuration: fuel_electricity) }

  let!(:fuel_gas)             { Schools::FuelConfiguration.new(has_gas: true) }
  let!(:school_2_config)      { create(:configuration, school: school_2, fuel_configuration: fuel_gas) }

  let!(:fuel_solar_pv)        { Schools::FuelConfiguration.new(has_solar_pv: true) }
  let!(:school_3_config)      { create(:configuration, school: school_3, fuel_configuration: fuel_solar_pv) }

  it 'provides JSON for all schools' do
    json = Maps::SchoolFeatures.new([school_1, school_2, school_3]).as_json

    expect(json['type']).to eq('FeatureCollection')
    expect(json['features'].count).to eq(3)

    feature = json['features'][0]
    expect(feature['type']).to eq('Feature')
    expect(feature['geometry']['type']).to eq('Point')
    expect(feature['geometry']['coordinates']).to eq([-2.30142, 51.34062])

    expect(feature['properties']['schoolPopupHtml']).to include(school_1.name) # school name
    expect(feature['properties']['schoolPopupHtml']).to include("Pupils: #{school_1.number_of_pupils}") # number of pupils
    expect(feature['properties']['schoolPopupHtml']).to include('<i class="fas fa-bolt">') # has electricity
    expect(feature['properties']['schoolPopupHtml']).not_to include('<i class="fas fa-fire">') # does not have gas
    expect(feature['properties']['schoolPopupHtml']).not_to include('<i class="fas fa-sun">') # does not have solar pv

    feature = json['features'][1]
    expect(feature['type']).to eq('Feature')
    expect(feature['geometry']['type']).to eq('Point')
    expect(feature['geometry']['coordinates']).to eq([-2.30142, 51.34062])
    expect(feature['properties']['schoolPopupHtml']).to include(school_2.name) # school name
    expect(feature['properties']['schoolPopupHtml']).to include("Pupils: #{school_2.number_of_pupils}") # number of pupils
    expect(feature['properties']['schoolPopupHtml']).not_to include('<i class="fas fa-bolt">') # does not hav electricity
    expect(feature['properties']['schoolPopupHtml']).to include('<i class="fas fa-fire">') # has gas
    expect(feature['properties']['schoolPopupHtml']).not_to include('<i class="fas fa-sun">') # does not have solar pv

    feature = json['features'][2]
    expect(feature['type']).to eq('Feature')
    expect(feature['geometry']['type']).to eq('Point')
    expect(feature['geometry']['coordinates']).to eq([-2.30142, 51.34062])
    expect(feature['properties']['schoolPopupHtml']).to include(school_3.name) # school name
    expect(feature['properties']['schoolPopupHtml']).to include("Pupils: #{school_3.number_of_pupils}") # number of pupils
    expect(feature['properties']['schoolPopupHtml']).not_to include('<i class="fas fa-bolt">') # does not have electricity
    expect(feature['properties']['schoolPopupHtml']).not_to include('<i class="fas fa-fire">') # does not have gas
    expect(feature['properties']['schoolPopupHtml']).to include('<i class="fas fa-sun">') # has solar pv
  end

end
