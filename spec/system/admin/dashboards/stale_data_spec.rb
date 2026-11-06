# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin dashboard stale data report' do
  before do
    admin = create(:admin, operations: true)
    sign_in admin
    visit admin_dashboard_stale_data_path(admin)
  end

  it 'shows the stale data report' do
    expect(page).to have_text('Meters with stale data')
    expect(page).to have_link('View all stale data meters', href: admin_reports_stale_data_path)
  end
end
