require 'rails_helper'

describe 'Management dashboard' do

  let!(:school){ create(:school) }
  let(:management){ create(:management, school: school) }

  before(:each) do
    sign_in(management)
  end

  it 'allows login and access to management dashboard' do
    visit root_path
    expect(page).to have_content("#{school.name} management dashboard")
  end

end
