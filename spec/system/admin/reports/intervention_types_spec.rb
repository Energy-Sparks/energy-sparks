# frozen_string_literal: true

require 'rails_helper'

describe 'intervention type reports' do
  let(:admin) { create(:admin) }
  let!(:intervention_type) { create(:intervention_type) }
  let!(:observation) { create(:observation, :intervention, intervention_type:, school: create(:school, :with_school_group)) }

  before do
    sign_in(admin)
    visit admin_reports_path
  end

  context 'with the intervention type management report' do
    before do
      click_on 'Intervention type management report'
    end

    it 'displays the report' do
      expect(page).to have_content('Intervention Type Management Report')
      expect(page).to have_content(intervention_type.name)
      expect(page).to have_link(intervention_type.name, href: admin_reports_intervention_type_path(intervention_type))
      expect(page).to have_link('Report', href: admin_reports_intervention_type_path(intervention_type))
    end
  end

  context 'with the intervention type report' do
    before do
      visit admin_reports_intervention_type_path(intervention_type)
    end

    it 'displays the report' do
      expect(page).to have_content intervention_type.name
      expect(page).to have_content observation.school.name
      expect(page).to have_link(observation.school.name,
                                href: school_url(observation.school, host: 'example.com'))
    end

    context 'when the activity has been recorded multiple times' do
      it 'includes a summary' do
        create(:observation, :intervention, intervention_type:, school: observation.school)
        refresh
        expect(page).to have_content('This intervention has been recorded multiple times by some schools')
      end
    end
  end
end
