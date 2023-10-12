require 'rails_helper'

RSpec.describe Admin::ActivityTypePreviewsController, type: :controller do
  context "As an admin user" do
    before do
      sign_in_user(:admin)
    end

    describe "POST #create" do
      it "uses content from school_specific_description to interpolate content" do
        post :create, params: { activity_type: { school_specific_description: 'some description' } }
        expect(assigns(:activity_type_content)).to include('some description')
      end

      it "uses locale specific field if specified" do
        post :create, params: { locale: 'cy', activity_type: { school_specific_description_en: 'some english description', school_specific_description_cy: 'some welsh description' } }
        expect(assigns(:activity_type_content)).to include('some welsh description')
      end
    end
  end
end
