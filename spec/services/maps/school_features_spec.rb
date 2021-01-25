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


  it 'provides JSON for all schools' do
    json = Maps::SchoolFeatures.new([school_1, school_2, school_3]).as_json

    expect(json['type']).to eq('FeatureCollection')
    expect(json['features'].count).to eq(3)

    feature = json['features'][0]
    expect(feature['type']).to eq('Feature')
    expect(feature['geometry']['type']).to eq('Point')
    expect(feature['geometry']['coordinates']).to eq([-2.30142, 51.34062])
    expect(feature['properties']['schoolName']).to eq('My School 1')
    expect(feature['properties']['number_of_pupils']).to eq(100)
    expect(feature['properties']['has_electricity']).to eq(true)
    expect(feature['properties']['has_gas']).to eq(false)

    feature = json['features'][1]
    expect(feature['type']).to eq('Feature')
    expect(feature['geometry']['type']).to eq('Point')
    expect(feature['geometry']['coordinates']).to eq([-2.30142, 51.34062])
    expect(feature['properties']['schoolName']).to eq('My School 2')
    expect(feature['properties']['number_of_pupils']).to eq(200)
    expect(feature['properties']['has_electricity']).to eq(false)
    expect(feature['properties']['has_gas']).to eq(true)

    feature = json['features'][2]
    expect(feature['type']).to eq('Feature')
    expect(feature['geometry']['type']).to eq('Point')
    expect(feature['geometry']['coordinates']).to eq([-2.30142, 51.34062])
    expect(feature['properties']['schoolName']).to eq('My School 3')
    expect(feature['properties']['number_of_pupils']).to eq(300)
    expect(feature['properties']['has_electricity']).to eq(false)
    expect(feature['properties']['has_gas']).to eq(false)
  end

end
