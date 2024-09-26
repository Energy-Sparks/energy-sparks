require 'rails_helper'

RSpec.describe 'electricity recent changes advice page', type: :system do
  let(:key) { 'electricity_recent_changes' }
  let(:expected_page_title) { 'Electricity recent changes analysis' }

  include_context 'electricity advice page'

  it_behaves_like 'it responds to HEAD requests'

  context 'as school admin' do
    let(:user) { create(:school_admin, school: school) }

    before do
      sign_in(user)
      visit school_advice_electricity_recent_changes_path(school)
    end

    it_behaves_like 'an advice page tab', tab: 'Insights'

    context "clicking the 'Insights' tab" do
      before { click_on 'Insights' }

      it_behaves_like 'an advice page tab', tab: 'Insights'

      it 'shows expected content' do
        expect(page).to have_content('What do we mean by recent changes?')
        expect(page).to have_content('Your recent electricity use')
        expect(page).to have_content(12)
      end
    end

    context "clicking the 'Analysis' tab" do
      before do
        click_on 'Analysis'
      end

      it_behaves_like 'an advice page tab', tab: 'Analysis'

      it 'shows titles' do
        expect(page).to have_content('Comparison of electricity use over 2 recent weeks')
        expect(page).to have_content('Comparison of electricity use over 2 recent days')
      end

      it 'shows start and end dates' do
        expected_start_date = start_date.to_fs(:es_full)
        expected_end_date = end_date.to_fs(:es_full)
        expect(page).to have_content("Electricity data is available from #{expected_start_date} to #{expected_end_date}")
      end

      it 'does not shows meter filtering chart options for both charts' do
        all('#chart-filter').each do |filters|
          within filters do
            expect(page).not_to have_select('Which meter?')
          end
        end
      end

      context 'when school has multiple meters' do
        before do
          create_list(:electricity_meter, 2, school: school)
          school.configuration.update!(fuel_configuration: Schools::FuelConfiguration.new(has_electricity: true))
          refresh
        end

        it 'shows meter filtering chart options for both charts' do
          all('#chart-filter').each do |filters|
            within filters do
              expect(page).to have_select('Which meter?')
            end
          end
        end
      end

      it 'shows expected content' do
        expect(page).to have_content('Comparison of electricity use over 2 recent weeks')
        expect(page).to have_content('Comparison of electricity use over 2 recent days')
        expect(page).to have_css('#chart_wrapper_calendar_picker_electricity_week_example_comparison_chart')
        expect(page).to have_css('#chart_wrapper_calendar_picker_electricity_day_example_comparison_chart')
        expect(page).to have_css('#chart_wrapper_intraday_line_school_last7days')
      end
    end

    context "clicking the 'Learn More' tab" do
      before { click_on 'Learn More' }

      it_behaves_like 'an advice page tab', tab: 'Learn More'
    end
  end
end
