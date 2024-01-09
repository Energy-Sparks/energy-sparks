# frozen_string_literal: true

require 'rails_helper'

describe Schools::UsageController do
  describe 'GET #show' do
    let(:school) do
      school = create(:school, :with_fuel_configuration)
      create(:electricity_meter_with_validated_reading, reading_count: 10, school: school)
      school
    end

    it 'responds successfully' do
      get :show, params: { school_id: school.to_param, supply: 'electricity', period: 'daily' }
      expect(response).to be_successful
    end

    it 'handles invalid parameters' do
      get :show, params: { school_id: school.to_param, supply: 'something', period: 'daily' }
      expect(response).to have_http_status(:redirect)
    end
  end
end
