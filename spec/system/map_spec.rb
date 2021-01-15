require 'rails_helper'

describe "map", type: :system do

  let!(:school)  { create(:school, latitude: 51.34062, longitude: -2.30142) }

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

  it 'gets the locations in GeoJSON format' do
    get '/map.json'
    json = JSON.parse(response.body)
    expect(json['type']).to eq('FeatureCollection')
    expect(json['features'][0]['type']).to eq('Feature')
    expect(json['features'][0]['geometry']['type']).to eq('Point')
    expect(json['features'][0]['geometry']['coordinates']).to eq([school.longitude, school.latitude])
    expect(json['features'][0]['properties']['schoolName']).to eq(school.name)
  end
end
