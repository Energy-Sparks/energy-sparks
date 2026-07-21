# frozen_string_literal: true

require 'rails_helper'

describe 'manage organisation impact statement' do
  include ActionView::Helpers::NumberHelper

  let(:user) { create(:admin) }

  before do
    sign_in(user)
    visit admin_path
  end

  context 'when adding a new statement' do
    before do
      click_on 'Organisational Impact Statements'
      click_on 'New statement'
    end

    context 'with valid data' do
      before do
        fill_in 'Academic year', with: '2026/27'
        fill_in 'Efficiency report link', with: 'http://example.org/efficiency_report_link'

        fill_in 'Schools', with: 1000
        fill_in 'Pupils', with: 10_000
        fill_in 'Staff', with: 200
        fill_in 'Activities', with: 1200
        fill_in 'Actions', with: 1500

        fill_in 'Total cost savings', with: 1_000_000
        fill_in 'Total carbon savings', with: 1000

        fill_in 'Primary saving electricity', with: 67
        fill_in 'Primary saving gas', with: 76
        fill_in 'Primary cost saving', with: 987
        fill_in 'Primary carbon saving', with: 7000

        fill_in 'Secondary saving electricity', with: 33
        fill_in 'Secondary saving gas', with: 89
        fill_in 'Secondary cost saving', with: 1999
        fill_in 'Secondary carbon saving', with: 8000

        click_on 'Save'
      end

      it 'Creates the record' do # rubocop:disable RSpec/ExampleLength
        expect(page).to have_text('Organisation statement has been created')
        expect(ImpactReport::OrganisationStatement.last).to have_attributes(
          academic_year: '2026/27',
          current: false,
          efficiency_report_link: 'http://example.org/efficiency_report_link',
          schools: 1000,
          pupils: 10_000,
          staff: 200,
          activities: 1200,
          actions: 1500,
          total_cost_savings: 1_000_000,
          total_carbon_savings: 1000,
          primary_saving_electricity: 67,
          primary_saving_gas: 76,
          primary_cost_saving: 987,
          primary_carbon_saving: 7000,
          secondary_saving_electricity: 33,
          secondary_saving_gas: 89,
          secondary_cost_saving: 1999,
          secondary_carbon_saving: 8000
        )
      end
    end

    context 'with invalid data' do
      it { expect { click_on 'Save' }.not_to change(ImpactReport::OrganisationStatement, :count) }

      it 'displays errors' do
        click_on 'Save'
        expect(page).to have_text("Academic year can't be blank")
      end
    end
  end

  context 'when editing a statement' do
    subject!(:statement) { create(:impact_report_organisation_statement) }

    before do
      click_on 'Organisational Impact Statements'
      click_on 'Edit'
      fill_in 'Academic year', with: '2026/27'
      fill_in 'Efficiency report link', with: 'http://example.org/efficiency_report_link'
      fill_in 'Schools', with: 1000
      fill_in 'Pupils', with: 10_000
      fill_in 'Staff', with: 200
      fill_in 'Activities', with: 1200
      fill_in 'Actions', with: 1500

      fill_in 'Total cost savings', with: 1_000_000
      fill_in 'Total carbon savings', with: 1000

      fill_in 'Primary saving electricity', with: 67
      fill_in 'Primary saving gas', with: 76
      fill_in 'Primary cost saving', with: 987
      fill_in 'Primary carbon saving', with: 7000

      fill_in 'Secondary saving electricity', with: 33
      fill_in 'Secondary saving gas', with: 89
      fill_in 'Secondary cost saving', with: 1999
      fill_in 'Secondary carbon saving', with: 8000

      click_on 'Save'
    end

    it 'Updates the record' do # rubocop:disable RSpec/ExampleLength
      expect(page).to have_text('Organisation statement has been updated')
      expect(statement.reload).to have_attributes(
        academic_year: '2026/27',
        current: false,
        efficiency_report_link: 'http://example.org/efficiency_report_link',
        schools: 1000,
        pupils: 10_000,
        staff: 200,
        activities: 1200,
        actions: 1500,
        total_cost_savings: 1_000_000,
        total_carbon_savings: 1000,
        primary_saving_electricity: 67,
        primary_saving_gas: 76,
        primary_cost_saving: 987,
        primary_carbon_saving: 7000,
        secondary_saving_electricity: 33,
        secondary_saving_gas: 89,
        secondary_cost_saving: 1999,
        secondary_carbon_saving: 8000
      )
    end
  end

  context 'when deleting a statement' do
    context 'when not current' do
      before do
        create(:impact_report_organisation_statement)
        click_on 'Organisational Impact Statements'
      end

      it { expect { click_on 'Delete' }.to change(ImpactReport::OrganisationStatement, :count).by(-1) }
    end

    context 'when current' do
      before do
        create(:impact_report_organisation_statement, :current)
        click_on 'Organisational Impact Statements'
      end

      it { expect(page).to have_no_button('Delete') }
    end
  end

  context 'when viewing a statement' do
    subject!(:statement) { create(:impact_report_organisation_statement) }

    before do
      click_on 'Organisational Impact Statements'
      click_on statement.academic_year
    end

    it 'shows overview fields' do
      expect(page).to have_text(number_with_delimiter(statement.schools))
      expect(page).to have_text(number_with_delimiter(statement.pupils))
      expect(page).to have_text(number_with_delimiter(statement.staff))
      expect(page).to have_text(number_with_delimiter(statement.activities))
      expect(page).to have_text(number_with_delimiter(statement.actions))
    end

    it 'shows total savings' do
      expect(page).to have_text(number_with_delimiter(statement.total_carbon_savings))
      expect(page).to have_text(number_with_delimiter(statement.total_cost_savings))
    end

    %i[primary secondary].each do |school_type|
      it "shows #{school_type} savings" do
        expect(page).to have_text(number_with_delimiter(statement.attributes["#{school_type}_saving_electricity"]))
        expect(page).to have_text(number_with_delimiter(statement.attributes["#{school_type}_saving_gas"]))
        expect(page).to have_text(number_with_delimiter(statement.attributes["#{school_type}_cost_saving"]))
        expect(page).to have_text(number_with_delimiter(statement.attributes["#{school_type}_carbon_saving"]))
      end
    end
  end
end
