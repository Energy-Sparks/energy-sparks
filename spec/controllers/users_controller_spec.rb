require 'rails_helper'

RSpec.describe UsersController, type: :controller do

  context "As an admin user" do
    before(:each) do
      sign_in_user(:admin)
    end
    describe "GET #index" do
      it "assigns all users as @users" do
        user = FactoryGirl.create :user
        get :index, params: {}
        expect(assigns(:users)).to include user
      end
      it "returns http success" do
        get :index
        expect(response).to have_http_status(:success)
      end
    end
  end

  context "As a guest user" do
    before(:each) do
      sign_in_user(:guest)
    end
    describe "GET #index" do
      it "redirects to the root url" do
        get :index, params: {}
        expect(response).to redirect_to(root_url)
      end
    end
  end
end
