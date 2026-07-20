# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Commercial::LicensingSummaryComponent, :include_application_helper, :include_url_helpers,
               type: :component do
  let!(:school) { create(:school) }
  let!(:licence) do
    create(:commercial_licence,
           school:,
           start_date: date_range.begin,
           end_date: date_range.end)
  end

  let(:date_range) { Date.new(2025, 9, 1)..Date.new(2026, 8, 31) }

  context 'when showing a single range' do
    before do
      render_inline described_class.new(first_range:
        date_range.begin..date_range.end,
                                        id: 'custom-id',
                                        classes: 'extra-classes',
                                        show_data_visibility: true) do |c|
        c.with_row id: "custom-school-id-#{school.id}", school: school, show_data_visibility: true
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
            ['', 'Current Academic Year', ''],
            ['School', 'Data visible', 'Licensed?', 'Funder', 'First licence start', 'First licence end', '']
          ]
        end
        let(:expected_rows) do
          [
            [
              school.name,
              'Yes',
              'Full',
              licence.contract.contract_holder.name,
              licence.start_date.to_fs(:es_short),
              licence.end_date.to_fs(:es_short),
              ''
            ]
          ]
        end
      end
    end
  end

  context 'when showing two ranges' do
    before do
      create(:commercial_licence,
             school:,
             start_date: date_range.end + 1,
             end_date: date_range.end + 30)
      render_inline described_class.new(first_range: date_range.begin..date_range.end,
                                        second_range: (date_range.end + 1)..(date_range.end + 364),
                                        labels: { first: 'Current Year', second: 'Following Year' },
                                        show_data_visibility: true,
                                        id: 'custom-id',
                                        classes: 'extra-classes') do |c|
        c.with_row id: "custom-school-id-#{school.id}", school: school, show_data_visibility: true
      end
    end

    it_behaves_like 'it contains the expected data table', sortable: true, aligned: false do
      let(:table_id) { '#summary-table' }
      let(:expected_header) do
        [
          ['', 'Current Year', 'Following Year', ''],
          [
            'School', 'Data visible',
            'Licensed?', 'Funder', 'First licence start', 'First licence end',
            'Licensed?', 'Funder', 'First licence start', 'First licence end',
            ''
          ]
        ]
      end
      let(:expected_rows) do
        [
          [
            school.name,
            'Yes',
            'Full',
            licence.contract.contract_holder.name,
            licence.start_date.to_fs(:es_short),
            licence.end_date.to_fs(:es_short),
            'Partial',
            school.licences.by_start_date.last.contract_holder.name,
            school.licences.by_start_date.last.start_date.to_fs(:es_short),
            school.licences.by_start_date.last.end_date.to_fs(:es_short),
            ''
          ]
        ]
      end
    end
  end
end
