require "rails_helper"

RSpec.describe Admin::PartnersController, type: :controller do
  include ActionDispatch::TestProcess

  let(:valid_attributes)          {
    {
      name: "BANES",
      position: 1,
      image: fixture_file_upload('images/banes.png','image/png'),
      url: "https://example.org"
    }
  }

  let(:invalid_attributes)        {
    {
      name: "BANES",
      url: "https://example.org"
    }
  }

  let(:partner)                   { create(:partner) }

  context "as an admin user" do
    before(:each) do
      sign_in_user(:admin)
    end

    describe "GET #index" do

      it "lists the partners" do
        get :index, params: {}
        expect(assigns(:partners)).to match_array([partner])
      end

    end

    describe "GET #show" do
      it "displays the partner" do
        get :show, params: { id: partner.to_param }
        expect(assigns(:partner)).to eql(partner)
        expect(response).to render_template("show")
      end
    end

    describe "POST #create" do
      context "with valid attributes" do
        it "creates the partner" do
          expect {
            post :create, params: { partner: valid_attributes }
          }.to change(Partner, :count).by(1)
        end
        it "redirects to partner list" do
          post :create, params: { partner: valid_attributes }
          expect(response).to redirect_to admin_partners_path
        end
      end

      context "with invalid attributes" do
        it "shows the template again" do
          post :create, params: { partner: invalid_attributes }
          expect(assigns(:partner)).to be_a_new(Partner)
          expect(response).to render_template("new")
        end
      end
    end

    describe "PUT #update" do
      context "with valid attributes" do
        let(:new_attributes) {
          { name: "New name", url: "http://another.example.org", position: 2 }
        }

        it "updates the model" do
          put :update, params: { id: partner.to_param, partner: new_attributes}
          partner.reload
          expect(partner.name).to eql new_attributes[:name]
          expect(partner.url).to eql new_attributes[:url]
          expect(partner.position).to eql new_attributes[:position]
        end
      end

      context "with invalid attributes" do
        it "shows the form again" do
          put :update, params: { id: partner.to_param, partner: { position: nil } }
          expect(response).to render_template("edit")
        end
      end

    end

    describe "DELETE #destroy" do
      it "removes the partner" do
        partner
        expect {
          delete :destroy, params: { id: partner.to_param }
        }.to change(Partner, :count).by(-1)
      end
    end

    describe "with school groups" do
      let(:school_group)    { create(:school_group) }
      before(:each) do
        partner.school_groups << school_group
      end
      it "removes the partner" do
        expect {
          delete :destroy, params: { id: partner.to_param }
        }.to change(Partner, :count).by(-1)
        expect(SchoolGroupPartner.count).to eql(0)
        expect(SchoolGroup.count).to eql(1)
      end
    end
  end
end
