require 'rails_helper'

RSpec.describe "pupils school view", type: :system do

  let(:school_name) { 'Theresa Green Infants'}
  let!(:school) { create(:school, name: school_name)}
  let!(:user)  { create(:user, role: :school_user, school: school)}

  describe 'when logged in as pupil' do
    before(:each) do
      sign_in(user)
    end

    it 'I can visit the pupil dashboard' do
      visit pupils_school_path(school)
      expect(page.has_content? school_name).to be true
    end
  end
end
