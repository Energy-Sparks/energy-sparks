# frozen_string_literal: true

require 'rails_helper'

describe 'hot_water_efficiency' do
  let!(:school) { create(:school) }
  let(:key) { :hot_water_efficiency }
  let(:advice_page_key) { :hot_water }
  let(:variables) do
    {
      avg_gas_per_pupil_gbp: 6.253909100526937,
      benchmark_existing_gas_efficiency: 0.13641467860927484,
      benchmark_gas_better_control_saving_gbp: 912.590927914895,
      benchmark_point_of_use_electric_saving_gbp: 259.88822973489596
    }
  end
  let(:alert_type) { create(:alert_type, class_name: 'AlertHotWaterEfficiency') }
  let(:alert_run) { create(:alert_generation_run, school: school) }
  let!(:report) { create(:report, key: key) }

  let!(:alerts) do
    create(:alert, school: school, alert_generation_run: alert_run, alert_type: alert_type, variables: variables)
  end

  before do
    create(:advice_page, key: advice_page_key)
  end

  context 'when viewing report' do
    it_behaves_like 'a school comparison report' do
      let(:expected_report) { report }
    end

    it_behaves_like 'a school comparison report with a table' do
      let(:expected_report) { report }
      let(:expected_school) { school }

      let(:advice_page_path) { polymorphic_path([:insights, expected_school, :advice, advice_page_key]) }

      let(:headers) do
        ['School',
         'Cost per pupil',
         'Efficiency of system',
         'Saving improving timing',
         'Saving with POU electric hot water']
      end

      let(:expected_table) do
        [headers,
         [school.name, '£6.25', '13.6&percnt;', '£913', '£260']]
      end

      let(:expected_csv) do
        [headers,
         [school.name, '6.25', '13.6', '913', '260']]
      end
    end

    it_behaves_like 'a school comparison report with a chart' do
      let(:expected_report) { report }
    end
  end

  context 'when there are schools with swimming pools' do
    let!(:other_school) { create(:school, has_swimming_pool: true) }

    before do
      create(:alert, school: other_school, alert_generation_run: alert_run, alert_type: alert_type, variables: variables)
      Comparison.const_get(key.to_s.camelize).refresh
      visit "/comparisons/#{key}"
    end

    it 'still has a single school' do
      within("##{report.key}-table") do
        expect(page).to have_link(school.name)
        expect(page).not_to have_link(other_school.name)
      end
    end

    it 'has custom unlisted message' do
      expect(page).to have_content('1 school could not be shown in this report as it does not have enough data to be analysed, or has a swimming pool so its hot water usage cannot be accurately estimated')
    end

    context 'when opening the modal', js: true do
      before { click_on 'View school' }

      it 'displays the school name and whether it has a swimming pool' do
        within '.modal-body' do
          expect(page).to have_link other_school.name, href: school_path(other_school)
          expect(page).to have_content 'Yes'
        end
      end
    end
  end
end
