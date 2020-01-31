require 'rails_helper'

describe "map", type: :system do

  let!(:school)  { create(:school, latitude: 51.34062, longitude: -2.30142) }

  let(:expected_geojson) {
    {
      "type"=>"FeatureCollection",
      "features"=> [
        {
          "type"=>"Feature",
          "geometry"=> {
            "type"=>"Point",
            "coordinates"=> [school.longitude, school.latitude] # From test stub in geocoder configuration
          },
          "properties"=>{
            "schoolName"=>school.name
          },
          "id"=>1
        }
      ]
    }
  }

  it 'gets the locations in GeoJSON format' do
    get '/map.json'
    parsed_body = JSON.parse(response.body)
    expect(parsed_body).to eq expected_geojson
  end
end
