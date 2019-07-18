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
    #sign_in(user)
    #visit root_path
    #visit new_school_programme_path
    #click_on 'Programme Types'
  end

  it 'allows the user to create, edit and delete a programme type' do
    expect(ProgrammeType.count).to be 1
    expect(ProgrammeType.first.activity_types.count).to be 3
    pp ProgrammeType.first.activity_types
  end

end