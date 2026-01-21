# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Image Feed' do
  let(:admin) { create(:admin) }

  before do
    sign_in(admin)
    visit admin_reports_path
  end

  context 'when viewing feed' do
    let!(:activity_no_image) { create(:activity, description: 'Activity no image') }
    let!(:observation_no_image) { create(:observation, :intervention, description: 'Intervention no image') }

    let!(:activity_with_image) do
      create(:activity_without_creator, :with_image_in_description, school: create(:school, :with_school_group))
    end

    let!(:observation_with_image) do
      create(:observation, :intervention_with_image_in_description, school: create(:school, :with_school_group))
    end

    before do
      click_on('Images')
    end

    it { expect(page).not_to have_content(activity_no_image.id) }
    it { expect(page).not_to have_content(observation_no_image.id) }

    it { expect(page).to have_content(activity_with_image.school.name) }
    it { expect(page).to have_content(observation_with_image.school.name) }
  end
end
