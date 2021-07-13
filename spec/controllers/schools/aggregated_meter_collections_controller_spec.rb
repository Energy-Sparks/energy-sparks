require 'rails_helper'

RSpec.describe Schools::AggregatedMeterCollectionsController, type: :controller do

  let(:admin)   { create(:admin) }

  let(:school)             { create(:school, visible: visible, public: public)}

  context "as an admin" do
    before(:each) do
      sign_in(:admin)
    end

    describe 'with visible school' do
      let(:visible) { true }

      context "that is public" do
        let(:public)  { true }
        it "can trigger a load" do
          post :post, format: :json, params: { school_id: school.id }
          expect(response).to have_http_status(200)
        end
      end

      context "that is private" do
        let(:public)  { false }
        it "can trigger a load" do
          post :post, format: :json, params: { school_id: school.id }
          expect(response).to have_http_status(200)
        end
      end
    end

    describe 'with invisible school' do
      let(:visible) { false }

      context "that is public" do
        let(:public)  { true }
        it "can trigger a load" do
          post :post, format: :json, params: { school_id: school.id }
          expect(response).to have_http_status(200)
        end
      end
      context "that is private" do
        let(:public)  { false }

        it "can trigger a load" do
          post :post, format: :json, params: { school_id: school.id }
          expect(response).to have_http_status(200)
        end
      end

    end

  end
end
