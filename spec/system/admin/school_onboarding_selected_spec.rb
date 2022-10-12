require 'rails_helper'

RSpec.describe 'admin school onboardings selectable actions', type: :system do

  let(:admin)         { create(:admin) }
  let(:school_group)  { create :school_group }

  describe 'when logged in' do
    let!(:setup_data)  { } # call to create all objects required by tests before page is loaded, overriden in contexts

    before do
      sign_in(admin)
      visit root_path
      click_on 'Manage'
      click_on 'Admin'
      click_on 'Manage school onboarding'
    end

    it_behaves_like "school group onboardings"

  end

end