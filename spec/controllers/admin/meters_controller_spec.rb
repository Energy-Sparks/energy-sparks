require 'rails_helper'

RSpec.describe Schools::MetersController, type: :controller do

  let(:valid_attributes) {
    {
      mpan_mprn: 2199989617206,
      name: "Test meter",
      meter_serial_number: "123",
      meter_type: :electricity,
      sandbox: "0"
    }
  }
  let(:invalid_attributes) {
    { mpan_mprn: nil }
  }

  let!(:school)           { create(:school) }

  context "as an admin user" do
    before(:each) do
      sign_in_user(:admin)
    end

    describe "POST #create" do
      context "with valid parameters" do
        it "creates a new Meter" do
          expect {
            post :create, params: { school_id: school.id, meter: valid_attributes }
          }.to change(Meter, :count).by(1)
        end
      end

      context "with invalid parameters" do
        it "assigns a newly created but unsaved meter as @meter" do
          post :create, params: { school_id: school.id, meter: invalid_attributes }
          expect(assigns(:meter)).to be_a_new(Meter)
        end

        it "re-renders the meters index" do
          post :create, params: { school_id: school.id, meter: invalid_attributes }
          expect(response).to render_template("index")
        end

      end

      context "with DCC sandbox meters" do
        let(:dcc_meter_attributes) {
          {
            mpan_mprn: 2199989617206,
            name: "Test meter",
            meter_serial_number: "123",
            meter_type: :electricity,
            sandbox: "1"
          }
        }
        it "creates a sandbox meter" do
          allow_any_instance_of(MeterManagement).to receive(:check_n3rgy_status).and_return(true)
          post :create, params: { school_id: school.id, meter: dcc_meter_attributes }
          expect(Meter.last.sandbox?).to be true
        end
      end
    end

    describe "PUT #update" do
      context "with valid attributes" do
        let(:new_attributes) {
          {
            mpan_mprn: 2199989617206,
            name: "Test meter",
            meter_serial_number: "123",
            meter_type: :electricity,
            dcc_meter: "0",
            consent_granted: "0"
          }
        }
      end

      context "when editing DCC values" do
        let(:new_attributes) {
          {
            mpan_mprn: 2199989617206,
            name: "New name",
            meter_serial_number: "123",
            meter_type: :electricity,
            dcc_meter: "1",
            sandbox: "1"
          }
        }
        let(:meter)             { create :electricity_meter, name: "Original name", school: school, dcc_meter: false }
        let(:n3rgy_api)         { double(:n3rgy_api) }
        let(:n3rgy_api_factory) { double(:n3rgy_api_factory, data_api: n3rgy_api) }

        it "sets as sandbox meter" do
          put :update, params: { school_id: school.id, id: meter.id, meter: new_attributes }
          meter.reload
          expect(meter.sandbox?).to eq true
        end

        it "allows DCC registered meters to be activated" do
          put :update, params: { school_id: school.id, id: meter.id, meter: new_attributes }
          meter.reload
          expect(meter.dcc_meter?).to eq true
        end
      end
    end

  end
end
