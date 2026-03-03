require 'rails_helper'

RSpec.describe 'manage school alert contacts', type: :system do
  let(:school) { create(:school) }
  let(:school2) { create(:school) }

  before do
    sign_in(user) if user.present?
  end

  context 'as a guest' do
    let(:user) { nil }

    it 'is not able to visit the alert contacts page and instead redirected to the log in page' do
      visit school_contacts_path(school)
      expect(page).to have_current_path(new_user_session_path, ignore_query: true)
    end
  end

  %i[pupil student].each do |role|
    context "as a #{role}" do
      let(:user) { create(role, school: school) }

      it 'is not able to visit the alert contacts page and instead redirected to the schools pupil page' do
        visit school_contacts_path(school)
        expect(page).to have_current_path(pupils_school_path(school), ignore_query: true)
      end
    end
  end

  context 'as staff user' do
    let(:user) { create(:staff, school: school) }

    it 'is able to visit the alert contacts page' do
      visit school_contacts_path(school)
      expect(page).to have_current_path(school_path(school), ignore_query: true)
    end
  end

  context 'as school_admin' do
    let(:user) { create(:school_admin, school: school) }

    it 'is able to visit the alert contacts page' do
      visit school_contacts_path(school)
      expect(page).to have_current_path(school_contacts_path(school), ignore_query: true)
    end
  end
end
