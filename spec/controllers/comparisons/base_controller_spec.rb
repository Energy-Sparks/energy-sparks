# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Comparisons::BaseController do
  # no templates so use :json requests
  controller do
    private

    def key = :key

    def load_data = []
  end

  describe 'GET #index' do
    let(:school_group) { create(:school_group) }

    before do
      create(:report, key: :key)
      create(:school, school_group:)
    end

    context 'with the school group layout' do
      it 'loads the selected school group' do
        get :index, params: { group: 'true', school_group_ids: [school_group.id.to_s] }, format: :json

        expect(response).to be_successful
        expect(assigns(:school_group_layout)).to be true
        expect(assigns(:school_group)).to eq(school_group)
      end

      it 'ignores blank IDs and loads the first selected school group' do
        other_school_group = create(:school_group)

        get :index,
            params: { group: 'true', school_group_ids: ['', school_group.id.to_s, other_school_group.id.to_s] },
            format: :json

        expect(response).to be_successful
        expect(assigns(:school_group)).to eq(school_group)
      end

      it 'requires school group IDs' do
        expect do
          get :index, params: { group: 'true' }, format: :json
        end.to raise_error(ActionController::ParameterMissing) { |error| expect(error.param).to eq(:school_group_ids) }
      end
    end

    context 'without the school group layout' do
      it 'does not require or load a school group' do
        get :index, format: :json

        expect(response).to be_successful
        expect(assigns(:school_group_layout)).to be false
        expect(assigns(:school_group)).to be_nil
      end
    end
  end
end
