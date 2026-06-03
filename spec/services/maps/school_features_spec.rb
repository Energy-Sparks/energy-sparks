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
  #       "id"=>1
  #     }
  #   ]
  # }
  let!(:school_1)             { create(:school, name: 'My School 1')}
  let!(:school_2)             { create(:school, name: 'My School 2')}
  let!(:school_3)             { create(:school, name: 'My School 3')}

  it 'provides JSON for all schools' do
    json = Maps::SchoolFeatures.new([school_1, school_2, school_3]).as_json

    expect(json['type']).to eq('FeatureCollection')
    expect(json['features'].count).to eq(3)

    feature = json['features'][0]
    expect(feature['type']).to eq('Feature')
    expect(feature['geometry']['type']).to eq('Point')
    expect(feature['geometry']['coordinates']).to eq([-2.30142, 51.34062])
    expect(feature['id']).to eq(school_1.id)

    feature = json['features'][1]
    expect(feature['type']).to eq('Feature')
    expect(feature['geometry']['type']).to eq('Point')
    expect(feature['geometry']['coordinates']).to eq([-2.30142, 51.34062])
    expect(feature['id']).to eq(school_2.id)

    feature = json['features'][2]
    expect(feature['type']).to eq('Feature')
    expect(feature['geometry']['type']).to eq('Point')
    expect(feature['geometry']['coordinates']).to eq([-2.30142, 51.34062])
    expect(feature['id']).to eq(school_3.id)
  end
end
