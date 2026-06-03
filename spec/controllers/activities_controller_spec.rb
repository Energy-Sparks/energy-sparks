# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivitiesController do
  let(:school) { create(:school) }
  let(:different_school) { create(:school) }
  let!(:activity_category) { create(:activity_category) }
  let!(:activity_type) { create(:activity_type, name: 'One', activity_category:, data_driven: true) }
  let(:activity_type2) { create(:activity_type, name: 'Two', activity_category:) }

  let(:valid_attributes) do
    { school_id: school.id,
      activity_type_id: activity_type.id,
      activity_category_id: activity_category.id,
      title: 'test title',
      description: '<div>Content</div>',
      happened_on: Time.zone.today }
  end

  let(:invalid_attributes) do
    { happened_on: nil }
  end

  describe 'GET #show' do
    it 'assigns the requested activity as @activity' do
      activity = create(:activity, school_id: school.id)
      get :show, params: { school_id: school.id, id: activity.to_param }
      expect(assigns(:activity)).to eq(activity)
    end

    context 'when school specific description includes charts' do
      let(:embedded_chart) { '{{#chart}}daytype_breakdown_gas{{/chart}}' }
      let(:activity) { create(:activity, school_id: school.id) }

      before do
        activity.activity_type.update(school_specific_description: "Embedded chart: #{embedded_chart}")
      end

      it 'includes button and radio tags, and data attributes' do
        get :show, params: { school_id: school.id, id: activity.to_param }
        expect(assigns(:activity_type_content).to_s).to include('<button class="btn ')
        expect(assigns(:activity_type_content).to_s).to include('<input type="radio" ')
        expect(assigns(:activity_type_content).to_s).to include('data-autoload-chart="true"')
      end
    end

    context 'when school specific description includes images' do
      let(:action_text_attachment) { '<action-text-attachment sgid="abc123" content-type="image/jpeg" url="http://test.com/rails/active_storage/blobs/pic.jpg" filename="pic.jpg" filesize="18205" width="350" height="450" previewable="true" presentation="gallery">' }
      let(:activity) { create(:activity, school_id: school.id) }

      before do
        activity.activity_type.update(school_specific_description: "Embedded image: #{action_text_attachment}")
      end

      it 'includes figure tag' do
        get :show, params: { school_id: school.id, id: activity.to_param }
        expect(assigns(:activity_type_content).to_s).to include('<figure class="attachment attachment--preview')
      end
    end

    context 'when school not data enabled' do
      before do
        school.update(data_enabled: false)
      end

      it 'with data-driven activity, it shows the generic description' do
        activity_type = create(:activity_type, data_driven: true)
        activity = create(:activity, school_id: school.id, activity_type:)
        get :show, params: { school_id: school.id, id: activity.to_param }
        expect(assigns(:activity_type_content).to_s).to include('generic description')
        expect(assigns(:activity_type_content).to_s).not_to include('school specific description')
      end

      it 'with non-data-driven activity, it shows the school specific description if present' do
        activity_type = create(:activity_type, data_driven: false)
        activity = create(:activity, school_id: school.id, activity_type:)
        get :show, params: { school_id: school.id, id: activity.to_param }
        expect(assigns(:activity_type_content).to_s).not_to include('generic description')
        expect(assigns(:activity_type_content).to_s).to include('school specific description')
      end

      it 'with non-data-driven activity, it shows the description if school specific description not present' do
        activity_type = create(:activity_type, data_driven: false, school_specific_description: nil)
        activity = create(:activity, school_id: school.id, activity_type:)
        get :show, params: { school_id: school.id, id: activity.to_param }
        expect(assigns(:activity_type_content).to_s).to include('generic description')
        expect(assigns(:activity_type_content).to_s).not_to include('school specific description')
      end
    end

    context 'when school is data enabled' do
      before do
        school.update(data_enabled: true)
      end

      it 'shows the school specific description if present' do
        activity = create(:activity, school_id: school.id)
        get :show, params: { school_id: school.id, id: activity.to_param }
        expect(assigns(:activity_type_content).to_s).not_to include('generic description')
        expect(assigns(:activity_type_content).to_s).to include('school specific description')
      end

      it 'shows the generic description if school specific description not present, but does not make html safe' do
        activity_type = create(:activity_type, data_driven: false, school_specific_description: nil)
        activity = create(:activity, school_id: school.id, activity_type:)
        get :show, params: { school_id: school.id, id: activity.to_param }
        expect(assigns(:activity_type_content).to_s).to include('generic description')
        expect(assigns(:activity_type_content).to_s).not_to include('school specific description')
      end
    end
  end

  describe 'GET #new' do
    context 'As an admin user' do
      before do
        sign_in_user(:admin)
      end

      it 'assigns a new activity as @activity' do
        get :new, params: { school_id: school.id }
        expect(assigns(:activity)).to be_a_new(Activity)
      end

      it 'properly defaults the category and activity' do
        get :new, params: { school_id: school.id, activity_type_id: activity_type2.id }
        expect(assigns(:activity)).to be_a_new(Activity)
        expect(assigns(:activity).activity_type).to eql(activity_type2)
        expect(assigns(:activity).activity_category).to eql(activity_category)
      end
    end

    it 'redirects when not authorised' do
      get :new, params: { school_id: school.id }
      expect(response).to have_http_status(:redirect)
    end
  end

  describe 'GET #edit' do
    before do
      sign_in_user(:admin)
    end

    it 'assigns the requested activity as @activity' do
      activity = create(:activity, school_id: school.id)
      get :edit, params: { school_id: school.id, id: activity.to_param }
      expect(assigns(:activity)).to eq(activity)
    end
  end

  describe 'POST #create' do
    let(:admin) { create(:admin) }

    before do
      sign_in(admin)
    end

    context 'with invalid params', toggle_feature: :todos do
      before do
        post :create, params: { school_id: school.id, activity: invalid_attributes }
      end

      it 'assigns a newly created but unsaved activity as @activity' do
        expect(assigns(:activity)).to be_a_new(Activity)
      end

      it "re-renders the 'new' template" do
        expect(response).to render_template('new')
      end
    end

    context 'with valid params', toggle_feature: :todos do
      before do
        post :create, params: { school_id: school.id, activity: valid_attributes }
      end

      it 'creates a new Activity' do
        expect(Activity.count).to be(1)
      end

      it 'assigns a newly created activity as @activity' do
        expect(assigns(:activity)).to be_a(Activity)
        expect(assigns(:activity)).to be_persisted
      end

      it 'redirects to the activity completed' do
        expect(response).to redirect_to(completed_school_activity_path(school, Activity.last))
      end
    end
  end

  describe 'DELETE #destroy' do
    before do
      sign_in_user(:admin)
    end

    it 'destroys the requested activity' do
      activity = Activity.create! valid_attributes
      expect do
        delete :destroy, params: { school_id: school.id, id: activity.to_param }
      end.to change(Activity, :count).by(-1)
    end

    it 'redirects to the activities index' do
      activity = Activity.create! valid_attributes
      delete :destroy, params: { school_id: school.id, id: activity.to_param }
      expect(response).to redirect_to(school_activities_path(school))
    end
  end

  describe 'PUT #update' do
    let(:admin) { create(:admin) }

    before do
      sign_in(admin)
    end

    context 'with valid params' do
      let(:new_attributes) do
        { title: 'new_title',
          description: 'new_description',
          activity_type_id: activity_type2.id,
          happened_on: Time.zone.today }
      end

      it 'updates the requested activity' do
        activity = Activity.create! valid_attributes
        put :update, params: { school_id: school.id, id: activity.to_param, activity: new_attributes }
        activity.reload
        expect(activity.title).to eq new_attributes[:title]
        expect(activity.description.to_plain_text).to eq new_attributes[:description]
        expect(activity.activity_type_id).to eq new_attributes[:activity_type_id]
        expect(activity.happened_on).to eq new_attributes[:happened_on]
        expect(activity.updated_by).to eq admin
      end

      it 'assigns the requested activity as @activity' do
        activity = Activity.create! valid_attributes
        put :update, params: { school_id: school.id, id: activity.to_param, activity: valid_attributes }
        expect(assigns(:activity)).to eq(activity)
      end

      it 'redirects to the activity' do
        activity = Activity.create! valid_attributes
        put :update, params: { school_id: school.id, id: activity.to_param, activity: valid_attributes }
        expect(response).to redirect_to(school_activity_path(school, activity))
      end
    end

    context 'with invalid params' do
      it 'assigns the activity as @activity' do
        activity = Activity.create! valid_attributes
        put :update, params: { school_id: school.id, id: activity.to_param, activity: invalid_attributes }
        expect(assigns(:activity)).to eq(activity)
      end

      it "re-renders the 'edit' template" do
        activity = Activity.create! valid_attributes
        put :update, params: { school_id: school.id, id: activity.to_param, activity: invalid_attributes }
        expect(response).to render_template('edit')
      end
    end
  end
end
