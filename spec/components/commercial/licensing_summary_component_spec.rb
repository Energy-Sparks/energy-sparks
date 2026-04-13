# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Commercial::LicensingSummaryComponent, :include_application_helper, :include_url_helpers,
               type: :component do
  let!(:school) { create(:school, default_contract_holder: create(:school_group)) }
  let!(:licence) do
    create(:commercial_licence,
           school:,
           start_date: date_range.begin,
           end_date: date_range.end)
  end

  let(:date_range) { Date.new(2025, 9, 1)..Date.new(2026, 8, 31) }

  before do
    render_inline described_class.new(date_range:
      date_range.begin..date_range.end,
                                      id: 'custom-id',
                                      classes: 'extra-classes') do |c|
      c.with_row id: "custom-school-id-#{school.id}", school: school
    end
  end

  it_behaves_like 'an application component' do
    let(:expected_classes) { 'extra-classes' }
    let(:expected_id) { 'custom-id' }
    let(:html) { page }
  end

  it 'includes the school id' do
    expect(page).to have_css("#custom-school-id-#{school.id}")
  end

  context 'when school has a current licence' do
    it_behaves_like 'it contains the expected data table', sortable: true, aligned: false do
      let(:table_id) { '#summary-table' }
      let(:expected_header) do
        [
          ['School', 'Current Licence?', 'Current Funder', 'Future Funder', 'Licenced for Period?', '']
        ]
      end
      let(:expected_rows) do
        [
          [
            school.name,
            'Yes',
            licence.contract.contract_holder.name,
            school.default_contract_holder&.name,
            'Full',
            ''
          ]
        ]
      end
    end
  end
end
