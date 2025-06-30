# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'good_job' do
  context 'when visiting the admin good job web page' do
    it 'is visible by an admin' do
      sign_in(create(:admin))
      visit admin_good_job_path
      expect(page).to have_content('GoodJob')
    end

    it 'is not visible by a non-admin' do
      sign_in(create(:school_admin))
      visit admin_good_job_path
      expect(page).to have_text(/^Routing Error\nNo route matches/)
    end
  end
end
