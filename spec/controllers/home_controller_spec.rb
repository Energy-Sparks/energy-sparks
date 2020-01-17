require 'rails_helper'

RSpec.describe HomeController, type: :controller do

  describe 'GET #index' do

    context 'where the user is not signed in' do

      it 'loads the homepage' do
        get :index
        expect(response).to render_template("index")
      end

    end

    context 'where the user is signed in' do

      context 'and the user has a school' do
        it 'redirects to the school page' do
          school = create(:school)
          sign_in_user(:school_admin, school.id)
          get :index
          expect(response).to redirect_to(school_path(school))
        end
      end

    end

  end

end
