require 'rails_helper'

describe 'programme', type: :system do

  let(:school_name) { 'Active school'}
  let!(:school) { create_active_school(name: school_name)}
  let!(:user)  { create(:user, role: 'school_user', school: school) }
  let!(:programme_type) { create(:programme_type_with_activity_types) }

  # let(:activity_type_name) { 'Exciting activity' }
  # let(:other_activity_type_name) { 'Exciting activity (please specify)' }
  # let(:activity_description) { 'What we did' }
  # let(:custom_title) { 'Custom title' }


  before do
    sign_in(user)
    visit root_path
    click_on 'See active programmes'
  end

  it 'allows the user see details of a programme' do
    expect(page).to have_content('Programmes')
    click_on programme_type.title
    expect(page).to have_content(programme_type.title)
    expect(page).to have_content(programme_type.description)
    expect(programme_type.activity_types.count).to be > 0
    programme_type.activity_types.each do |activity_type|
      expect(page).to have_content(activity_type.name)
    end

    click_on 'Start this programme'

  end
end