require 'rails_helper'

RSpec.describe 'good_job', type: :system do
  let(:admin) { create(:admin) }
  let(:user) { create(:user) }

  context 'the admin good job web page' do
    it 'is visible by an admin' do
      sign_in(admin)
      visit admin_good_job_path
      expect(page).to have_content('GoodJob')
    end

    it 'is not visible by a non-admin' do
      (User.roles.keys - ['admin']).each do |role|
        user.update(role: role)
        sign_in(user)
        expect { visit admin_good_job_path }.to raise_error(ActionController::RoutingError)
      end
    end
  end
end
