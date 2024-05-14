require 'rails_helper'

RSpec.describe Schools::MetersController, type: :controller do
  let(:valid_attributes) do
    {
      mpan_mprn: 2199989617206,
      name: 'Test meter',
      meter_serial_number: '123',
      meter_type: :electricity
    }
  end
  let(:invalid_attributes) do
    { mpan_mprn: nil }
  end

  let!(:school) { create(:school) }

  context 'as an admin user' do
    before do
      sign_in_user(:admin)
    end

    describe 'POST #create' do
      context 'with valid parameters' do
        it 'creates a new Meter' do
          expect do
            post :create, params: { school_id: school.id, meter: valid_attributes }
          end.to change(Meter, :count).by(1)
        end
      end

      context 'with invalid parameters' do
        it 'assigns a newly created but unsaved meter as @meter' do
          post :create, params: { school_id: school.id, meter: invalid_attributes }
          expect(assigns(:meter)).to be_a_new(Meter)
        end

        it 're-renders the meters index' do
          post :create, params: { school_id: school.id, meter: invalid_attributes }
          expect(response).to render_template('index')
        end
      end
    end

    describe 'PUT #update' do
      context 'with valid attributes' do
        let(:new_attributes) do
          {
            mpan_mprn: 2199989617206,
            name: 'Test meter',
            meter_serial_number: '123',
            meter_type: :electricity,
            dcc_meter: '0',
            consent_granted: '0'
          }
        end
      end

      context 'when editing DCC values' do
        let(:new_attributes) do
          {
            mpan_mprn: 2199989617206,
            name: 'New name',
            meter_serial_number: '123',
            meter_type: :electricity,
            dcc_meter: '1'
          }
        end
        let(:meter) { create :electricity_meter, name: 'Original name', school: school, dcc_meter: false }

        it 'allows DCC registered meters to be activated' do
          put :update, params: { school_id: school.id, id: meter.id, meter: new_attributes }
          meter.reload
          expect(meter.dcc_meter?).to eq true
        end
      end
    end
  end
end
