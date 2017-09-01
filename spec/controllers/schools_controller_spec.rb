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

  describe 'GET #scoreboard' do
    it 'assigns schools as @schools in points order' do
      schools = (1..5).collect { |n| create :school, :with_points, score_points: 6 - n }

      get :scoreboard
      expect(School.scoreboard.map(&:id)).to eq(schools.map(&:id))
    end

    context "as a school administrator" do
      let(:school) {
        school = FactoryGirl.create :school, enrolled: true
      }

      before(:each) do
        sign_in_user(:school_admin, school.id)
      end

      it 'doesnt award a badge if school has zero points' do
        get :scoreboard
        expect(school.badges.length).to eql(0)
      end
      it 'grants the a badge if school has 10 points' do
        school.add_points(20)
        get :scoreboard
        school.reload
        expect(school.badges.length).to eql(1)
        expect(school.badges.first.name).to eql("player")
      end
    end

  end

  describe "GET #index" do
    it "assigns schools that are enrolled as @schools_enrolled" do
      school = FactoryGirl.create :school, enrolled: true
      get :index, params: {}
      expect(assigns(:schools_enrolled)).to eq([school])
    end
    it "assigns schools that haven't enrolled as @schools_not_enrolled" do
      school = FactoryGirl.create :school, enrolled: false
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
          school = FactoryGirl.create :school, enrolled: false
          get :show, params: {id: school.to_param}
          expect(response).to redirect_to(enrol_path)
        end
      end
      context "the school is enrolled" do
        it "assigns the requested school as @school" do
          school = FactoryGirl.create :school
          get :show, params: {id: school.to_param}
          expect(assigns(:school)).to eq(school)
        end
        it "assigns the school's meters as @meters" do
          school = FactoryGirl.create :school
          meter = FactoryGirl.create :meter, school_id: school.id
          get :show, params: {id: school.to_param}
          expect(assigns(:meters)).to include(meter)
        end
        it "assigns the latest activities as @activities" do
          school = FactoryGirl.create :school
          activity = FactoryGirl.create :activity, school_id: school.id
          get :show, params: {id: school.to_param}
          expect(assigns(:activities)).to include(activity)
        end
        it "does not include activities from other schools" do
          school = FactoryGirl.create :school
          other_school = FactoryGirl.create :school
          FactoryGirl.create :activity, school_id: school.id
          activity_other_school = FactoryGirl.create :activity, school_id: other_school.id
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
    let!(:school) { FactoryGirl.create :school }
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
        school = FactoryGirl.create :school
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
        it "creates a calendar for the new School" do
          post :create, params: {school: valid_attributes}
          expect(assigns(:school).calendar).not_to be_nil
        end

        it "redirects to the created school" do
          post :create, params: {school: valid_attributes}
          expect(response).to redirect_to(School.last)
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
          school = FactoryGirl.create :school
          put :update, params: {id: school.to_param, school: new_attributes}
          school.reload
          expect(school.name).to eq new_attributes[:name]
        end

        it "assigns the requested school as @school" do
          school = FactoryGirl.create :school
          put :update, params: {id: school.to_param, school: valid_attributes}
          expect(assigns(:school)).to eq(school)
        end

        it "redirects to the school" do
          school = FactoryGirl.create :school
          put :update, params: {id: school.to_param, school: valid_attributes}
          expect(response).to redirect_to(school)
        end

        it "awards competitor badge" do
          school = FactoryGirl.create :school
          put :update, params: {id: school.to_param, school: {competition_role: "competitor"}}
          school.reload
          expect(school.badges[0].name).to eql("competitor")
        end
        it "awards winner badge" do
          school = FactoryGirl.create :school
          put :update, params: {id: school.to_param, school: {competition_role: "winner"}}
          school.reload
          expect(school.badges[0].name).to eql("winner")
        end

      end

      context "with invalid params" do
        it "assigns the school as @school" do
          school = FactoryGirl.create :school
          put :update, params: {id: school.to_param, school: invalid_attributes}
          expect(assigns(:school)).to eq(school)
        end

        it "re-renders the 'edit' template" do
          school = FactoryGirl.create :school
          put :update, params: {id: school.to_param, school: invalid_attributes}
          expect(response).to render_template("edit")
        end
      end
    end

    describe "DELETE #destroy" do
      it "destroys the requested school" do
        school = FactoryGirl.create :school
        expect {
          delete :destroy, params: {id: school.to_param}
        }.to change(School, :count).by(-1)
      end

      it "redirects to the schools list" do
        school = FactoryGirl.create :school
        delete :destroy, params: {id: school.to_param}
        expect(response).to redirect_to(schools_url)
      end
    end

  end
end
