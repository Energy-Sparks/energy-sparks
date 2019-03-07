require 'rails_helper'

RSpec.describe "teachers school view", type: :system do

  let(:school_name) { 'Theresa Green Infants'}
  let!(:school) { create(:school, name: school_name)}
  let!(:user)  { create(:user, role: :school_admin, school: school)}

  describe 'when logged in as teacher' do
    before(:each) do
      sign_in(user)
    end

    it 'I can visit the teacher dashboard' do
      visit teachers_school_path(school)
      expect(page.has_content? school_name).to be true
    end
  end
end
