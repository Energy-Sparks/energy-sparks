require 'rails_helper'

RSpec.describe "manage school alert contacts", type: :system do
  let(:school) { create(:school) }

  before(:each) do
    sign_in(user) if user.present?
  end

  context 'as a guest' do
    let(:user) { nil }
    it 'should not be able to visit the alert contacts page and instead redirected to the log in page' do
      visit school_contacts_path(school)
      expect(page.current_path).to eq(new_user_session_path)
    end
  end

  context 'as pupil' do
    let(:user) { create(:pupil, school: school) }
    it 'should not be able to visit the alert contacts page and instead redirected to the schools pupil page' do
      visit school_contacts_path(school)
      expect(page.current_path).to eq(pupils_school_path(school))
    end
  end
end
