require 'rails_helper'

RSpec.describe Teachers::SchoolsController, type: :controller do

  let(:school)          { create(:school) }

  describe "GET #show" do

    context "school not in cache" do
        before(:each) do
          allow(AggregateSchoolService).to receive(:caching_off?).and_return(false, true)
          allow_any_instance_of(AggregateSchoolService).to receive(:aggregate_school).and_return(school)
          sign_in_user(:school_admin, school.id)
        end

        it "shows error page" do
          get :show, params: {id: school.to_param}
          expect(assigns(:school)).to eq(school)
          expect(assigns(:number_of_weather_readings)).to eql(0)
          expect(assigns(:number_of_solar_pv_readings)).to eql(0)
          expect(response).to_not redirect_to(teachers_school_path(school))
          expect(response).to render_template("schools/aggregated_meter_collections/show")
        end

        it "shows weather count" do
          station = create(:weather_station)
          create(:weather_observation, weather_station: station, reading_date: '2020-01-01')
          school.update!(weather_station: station)

          get :show, params: {id: school.to_param}
          expect(assigns(:number_of_weather_readings)).to eql(48)
          expect(assigns(:number_of_solar_pv_readings)).to eql(0)
          expect(response).to_not redirect_to(teachers_school_path(school))
          expect(response).to render_template("schools/aggregated_meter_collections/show")
        end

    end
  end
end
