require 'rails_helper'

RSpec.describe SchoolsController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # School. As you add validations to School, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {urn: 12345, name: 'test school'}
  }

  let(:invalid_attributes) {
    {name: nil}
  }

  describe 'GET #suggest_activity' do
    let(:school) { FactoryBot.create :school }

    context "as a guest user" do
      it "is not authorised" do
        get :suggest_activity, params: { id: school.to_param }
        expect(response).to have_http_status(:redirect  )
      end
    end
    context "as an authorised school administrator" do

      let!(:ks1_tag) { ActsAsTaggableOn::Tag.create(name: 'KS1') }
      let!(:ks2_tag) { ActsAsTaggableOn::Tag.create(name: 'KS2') }
      let!(:ks3_tag) { ActsAsTaggableOn::Tag.create(name: 'KS3') }
      let!(:school) { create :school, enrolled: true, key_stages: [ks1_tag, ks3_tag] }

      let(:activity_category) { create :activity_category }
      let!(:activity_types) { create_list(:activity_type, 5, activity_category: activity_category, data_driven: true, key_stages: [ks1_tag, ks2_tag]) }

      before(:each) { sign_in_user(:school_user, school.id) }

      context "with a single activity type" do
        it "is authorised" do
          get :suggest_activity, params: { id: school.to_param }
          expect(response).to_not have_http_status(:redirect  )
          expect(assigns(:suggestions)).to match_array(activity_types)
        end
      end

      context "with no activity types set for the school" do
        it "suggests any 5 if no suggestions" do
          get :suggest_activity, params: { id: school.to_param }
          expect(assigns(:suggestions)).to match_array(activity_types)
        end
      end

      context "with initial suggestions" do
        let!(:activity_types_with_suggestions) { create_list(:activity_type, 5, :as_initial_suggestions, key_stages: [ks1_tag, ks2_tag])}
        it "suggests the first five initial suggestions" do
          get :suggest_activity, params: { id: school.to_param }
          expect(assigns(:suggestions)).to match_array(activity_types_with_suggestions)
        end
      end

      context "with suggestions based on last activity type" do
        let!(:activity_type_with_further_suggestions) { create :activity_type, :with_further_suggestions, number_of_suggestions: 5 }
        let!(:last_activity) { create :activity, school: school, activity_type: activity_type_with_further_suggestions }

        it "suggests the five follow ons from original" do
          get :suggest_activity, params: { id: school.to_param }
          expect(assigns(:suggestions)).to match_array(last_activity.activity_type.activity_type_suggestions.map(&:suggested_type))
        end
      end
    end
  end

  describe "GET #index" do
    it "assigns schools that are enrolled but not grouped as @ungrouped_enrolled_schools" do
      school = FactoryBot.create :school, enrolled: true
      get :index, params: {}
      expect(assigns(:ungrouped_enrolled_schools)).to eq([school])
    end
    it "assigns schools that haven't enrolled as @schools_not_enrolled" do
      school = FactoryBot.create :school, enrolled: false
      get :index, params: {}
      expect(assigns(:schools_not_enrolled)).to eq([school])
    end
  end

  describe "GET #show" do
    context "as a guest user" do
      before(:each) do
        sign_in_user(:guest)
      end
      context "when the school is not enrolled" do
        it "redirects to the enrol page" do
          sign_in_user(:guest)
          school = FactoryBot.create :school, enrolled: false
          get :show, params: {id: school.to_param}
          expect(response).to redirect_to(enrol_path)
        end
      end
      context "the school is enrolled" do
        it "assigns the requested school as @school" do
          school = FactoryBot.create :school
          get :show, params: {id: school.to_param}
          expect(assigns(:school)).to eq(school)
        end
        it "assigns the school's meters as @meters" do
          school = FactoryBot.create :school
          meter = FactoryBot.create :meter, school_id: school.id
          get :show, params: {id: school.to_param}
          expect(assigns(:meters)).to include(meter)
        end
        it "assigns the latest activities as @activities" do
          school = FactoryBot.create :school
          activity = FactoryBot.create :activity, school_id: school.id
          get :show, params: {id: school.to_param}
          expect(assigns(:activities)).to include(activity)
        end
        it "does not include activities from other schools" do
          school = FactoryBot.create :school
          other_school = FactoryBot.create :school
          FactoryBot.create :activity, school_id: school.id
          activity_other_school = FactoryBot.create :activity, school_id: other_school.id
          get :show, params: {id: school.to_param}
          expect(assigns(:activities)).not_to include activity_other_school
        end
        it "assigns the school's awards to @badges" do
          school = create :school, :with_badges, badges_sashes: 7

          get :show, params: {id: school.to_param}
          expect(assigns(:badges)).to include(school.badges.first)
        end
        it "doesn't include other schools badges" do
          school_one, school_two = create_pair :school, :with_badges, badges_sashes: 2

          get :show, params: {id: school_one.to_param}
          expect(assigns(:badges)).not_to include(school_two.badges.first)
        end
      end
    end
    context "as an admin user" do
      before(:each) do
        sign_in_user(:admin)
      end

    end
  end

  describe "GET #awards" do
    it 'assigns awards as @badges' do
      school = create :school, :with_badges

      get :awards, params: {id: school.to_param}
      expect(assigns(:badges)).to include(school.badges.first)
    end
  end

  describe "GET #usage" do
    let!(:school) { FactoryBot.create :school }
    let(:period) { :daily }
    it "assigns the requested school as @school" do
      get :usage, params: {id: school.to_param, period: period}
      expect(assigns(:school)).to eq(school)
    end
    context "to_date is specified" do
      let(:to_date) { Date.current - 1.days }
      it "assigns to_date to @to_date" do
        get :usage, params: {id: school.to_param, period: period, to_date: to_date}
        expect(assigns(:to_date)).to eq to_date.beginning_of_week(:sunday)
      end
    end
    context "period is 'daily'" do
      let(:period) { :daily }
      it "renders the daily_usage template" do
        get :usage, params: {id: school.to_param, period: period}
        expect(response).to render_template('daily_usage')
      end
    end
    context "period is 'hourly'" do
      let(:period) { :hourly }
      it "renders the hourly_usage template" do
        get :usage, params: {id: school.to_param, period: period}
        expect(response).to render_template('hourly_usage')
      end
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
        get :edit, params: {id: school.to_param}
        expect(assigns(:school)).to eq(school)
      end
    end

    describe "POST #create" do
      context "with valid params" do

        it "creates a new School" do
          expect {
            post :create, params: {school: valid_attributes}
          }.to change(School, :count).by(1)
        end
        it "assigns a newly created school as @school" do
          post :create, params: {school: valid_attributes}
          expect(assigns(:school)).to be_a(School)
          expect(assigns(:school)).to be_persisted
        end
      end

      context "with invalid params" do
        it "assigns a newly created but unsaved school as @school" do
          post :create, params: {school: invalid_attributes}
          expect(assigns(:school)).to be_a_new(School)
        end

        it "re-renders the 'new' template" do
          post :create, params: {school: invalid_attributes}
          expect(response).to render_template("new")
        end
      end
    end

    describe "PUT #update" do
      context "with valid params" do
        let(:new_attributes) {
          {name: 'new name'}
        }

        it "updates the requested school" do
          school = FactoryBot.create :school
          put :update, params: {id: school.to_param, school: new_attributes}
          school.reload
          expect(school.name).to eq new_attributes[:name]
        end

        it "assigns the requested school as @school" do
          school = FactoryBot.create :school
          put :update, params: {id: school.to_param, school: valid_attributes}
          expect(assigns(:school)).to eq(school)
        end

        it "redirects to the school" do
          school = FactoryBot.create :school
          put :update, params: {id: school.to_param, school: valid_attributes}
          expect(response).to redirect_to(school)
        end

      end

      context "with invalid params" do
        it "assigns the school as @school" do
          school = FactoryBot.create :school
          put :update, params: {id: school.to_param, school: invalid_attributes}
          expect(assigns(:school)).to eq(school)
        end

        it "re-renders the 'edit' template" do
          school = FactoryBot.create :school
          put :update, params: {id: school.to_param, school: invalid_attributes}
          expect(response).to render_template("edit")
        end
      end
    end

    describe "DELETE #destroy" do
      it "destroys the requested school" do
        school = FactoryBot.create :school
        expect {
          delete :destroy, params: {id: school.to_param}
        }.to change(School, :count).by(-1)
      end

      it "redirects to the schools list" do
        school = FactoryBot.create :school
        delete :destroy, params: {id: school.to_param}
        expect(response).to redirect_to(schools_url)
      end
    end

  end
end
