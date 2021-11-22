require 'rails_helper'

RSpec.describe 'activation', type: :system do

  let!(:admin)  { create(:admin)}

  let!(:school_group)  { create(:school_group, name: 'BANES') }
  let!(:not_visible)      { create(:school, name: "Not visible", school_group: school_group, visible: false)}
  let!(:not_data_visible) { create(:school, name: "Not data visible", school_group: school_group, visible: true, data_enabled: false)}

  before(:each) do
    sign_in(admin)
    visit admin_path
    click_on 'Schools awaiting activation'
  end

  it 'lists schools that are not visible' do
    expect(page).to have_content("Not visible")
  end

  it 'lists schools that are not data visible' do
    expect(page).to have_content("Not data visible")
  end

end
