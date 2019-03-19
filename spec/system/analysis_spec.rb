require 'rails_helper'

RSpec.describe "analysis view", type: :system do

  let(:school_name) { 'Theresa Green Infants'}
  let(:school)     { create(:school, name: school_name)}

  it 'I can visit the school analysis page' do
    visit school_analysis_path(school)
    expect(page.has_content? school_name).to be true
  end
end
