require 'rails_helper'

RSpec.describe SchoolsController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # School. As you add validations to School, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    attributes_for(:school)
  end

  let(:invalid_attributes) do
    { name: nil }
  end

  describe "GET #index" do
    it "assigns schools that are visible but not grouped as @ungrouped_visible_schools" do
      school = FactoryBot.create :school, visible: true
      get :index, params: {}
      expect(assigns(:ungrouped_visible_schools)).to eq([school])
    end
    it "assigns not visible schools as @schools_not_visible" do
      school = FactoryBot.create :school, visible: false
      get :index, params: {}
      expect(assigns(:schools_not_visible)).to eq([school])
    end
  end

  describe "GET #show" do
    it "shows the adult dashboard" do
      school = FactoryBot.create :school
      get :show, params: { id: school.to_param }
      expect(assigns(:school)).to eq(school)
      expect(response).to_not redirect_to(school_pupils_path(school))
    end
  end

  context "As an admin user" do
    before(:each) do
      sign_in_user(:admin)
    end

    describe "GET #new" do
      it "assigns a new school as @school" do
        get :new, params: {}
        expect(assigns(:school)).to be_a_new(School)
      end
    end

    describe "GET #edit" do
      it "assigns the requested school as @school" do
        school = FactoryBot.create :school
        get :edit, params: { id: school.to_param }
        expect(assigns(:school)).to eq(school)
      end
    end

    describe "POST #create" do
      context "with valid params" do
        it "creates a new School" do
          expect do
            post :create, params: { school: valid_attributes }
          end.to change(School, :count).by(1)
        end
        it "assigns a newly created school as @school" do
          post :create, params: { school: valid_attributes }
          expect(assigns(:school)).to be_a(School)
          expect(assigns(:school)).to be_persisted
        end
      end

      context "with invalid params" do
        it "assigns a newly created but unsaved school as @school" do
          post :create, params: { school: invalid_attributes }
          expect(assigns(:school)).to be_a_new(School)
        end

        it "re-renders the 'new' template" do
          post :create, params: { school: invalid_attributes }
          expect(response).to render_template("new")
        end
      end
    end

    describe "PUT #update" do
      context "with valid params" do
        let(:new_attributes) do
          { name: 'new name' }
        end

        it "updates the requested school" do
          school = FactoryBot.create :school
          put :update, params: { id: school.to_param, school: new_attributes }
          school.reload
          expect(school.name).to eq new_attributes[:name]
        end

        it "assigns the requested school as @school" do
          school = FactoryBot.create :school
          put :update, params: { id: school.to_param, school: valid_attributes }
          expect(assigns(:school)).to eq(school)
        end

        it "redirects to the school" do
          school = create(:school_with_same_name)
          put :update, params: { id: school.to_param, school: valid_attributes }
          school.reload
          expect(response).to redirect_to(school)
        end
      end

      context "with invalid params" do
        it "assigns the school as @school" do
          school = FactoryBot.create :school
          put :update, params: { id: school.to_param, school: invalid_attributes }
          expect(assigns(:school)).to eq(school)
        end

        it "re-renders the 'edit' template" do
          school = FactoryBot.create :school
          put :update, params: { id: school.to_param, school: invalid_attributes }
          expect(response).to render_template("edit")
        end
      end
    end

    describe "DELETE #destroy" do
      it "destroys the requested school" do
        school = FactoryBot.create :school
        expect do
          delete :destroy, params: { id: school.to_param }
        end.to change(School, :count).by(-1)
      end

      it "redirects to the schools list" do
        school = FactoryBot.create :school
        delete :destroy, params: { id: school.to_param }
        expect(response).to redirect_to(schools_url)
      end
    end
  end
end
