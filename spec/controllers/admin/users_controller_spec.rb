require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  let(:valid_attributes) do
    {
      name: 'User',
      email: 'school@test.com',
      password: 'testpassword',
      role: :staff,
      staff_role_id: create(:staff_role, :teacher).id,
      school_id: create(:school).id
    }
  end
  let(:invalid_attributes) do
    { email: nil }
  end

  context 'As an admin user' do
    before do
      sign_in_user(:admin)
    end

    describe 'GET #index' do
      it 'assigns all users as @users' do
        user = create :staff
        get :index, params: {}
        expect(assigns(:users)).to include user
      end

      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end
    end

    describe 'GET #new' do
      it 'assigns schools as @schools' do
        school = FactoryBot.create :school
        get :new, params: {}
        expect(assigns(:schools)).to include school
      end
    end

    describe 'GET #edit' do
      it 'assigns  schools as @schools' do
        user = create :staff
        get :edit, params: { id: user.to_param }
        expect(assigns(:schools)).to include user.school
      end
    end

    describe 'POST #create' do
      context 'with valid params' do
        it 'creates a new User' do
          expect do
            post :create, params: { user: valid_attributes }
          end.to change(User, :count).by(1)
        end

        it 'assigns a newly created user as @user' do
          post :create, params: { user: valid_attributes }
          expect(assigns(:user)).to be_a(User)
          expect(assigns(:user)).to be_persisted
        end

        it 'redirects to the created user' do
          post :create, params: { user: valid_attributes }
          expect(response).to redirect_to(admin_users_path)
        end
      end

      context 'with invalid params' do
        it 'assigns a newly created but unsaved user as @user' do
          post :create, params: { user: invalid_attributes }
          expect(assigns(:user)).to be_a_new(User)
        end

        it "re-renders the 'new' template" do
          post :create, params: { user: invalid_attributes }
          expect(response).to render_template('new')
        end
      end
    end

    describe 'PUT #update' do
      context 'with valid params' do
        let(:new_attributes) do
          { email: 'new@test.com' }
        end

        it 'updates the requested user' do
          user = create :staff
          put :update, params: { id: user.to_param, user: new_attributes }
          user.reload
          expect(user.email).to eq new_attributes[:email]
        end

        it 'assigns the requested user as @user' do
          user = create :staff
          put :update, params: { id: user.to_param, user: new_attributes }
          expect(assigns(:user)).to eq(user)
        end

        it 'redirects to the users' do
          user = create :staff
          put :update, params: { id: user.to_param, user: new_attributes }
          expect(response).to redirect_to(admin_users_path)
        end
      end

      context 'with invalid params' do
        it 'assigns the user as @user' do
          user = create :staff
          put :update, params: { id: user.to_param, user: invalid_attributes }
          expect(assigns(:user)).to eq(user)
        end

        it "re-renders the 'edit' template" do
          user = create :staff
          put :update, params: { id: user.to_param, user: invalid_attributes }
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'DELETE #destroy' do
      it 'destroys the requested user' do
        user = create :staff
        expect do
          delete :destroy, params: { id: user.to_param }
        end.to change(User, :count).by(-1)
      end

      it 'redirects to the users list' do
        user = create :staff
        delete :destroy, params: { id: user.to_param }
        expect(response).to redirect_to(admin_users_path)
      end
    end
  end
end
