# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Heating Types Reports' do
  before do
    create(:school, :with_school_group, heating_gas: true)
    sign_in(create(:admin))
    visit admin_reports_heating_types_path
  end

  it 'displays a list of heating types' do
    expect(page).to have_content('Heating Types')
    expect(page).to have_table('heating-types')
    expect(page).to have_table('school-heating-types')
  end
end
