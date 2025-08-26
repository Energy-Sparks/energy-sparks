# frozen_string_literal: true

require 'rails_helper'

def target_shared_examples(tab)
  context 'with shared examples' do
    before do
      create(:school_target, :with_monthly_consumption, school:, fuel_type:)
      visit_path(tab)
    end

    it_behaves_like 'an advice page tab', tab: do
      let(:expected_page_title) { "Progress towards reducing your #{fuel_string} use" }
    end
  end
end

RSpec.shared_examples 'target advice page' do
  let(:school) { create(:school, :with_fuel_configuration, :with_meter_dates, fuel_type:) }
  let(:key) { "#{fuel_type}_target" }
  let!(:advice_page) { create(:advice_page, key:, restricted: false, fuel_type:) }

  before do
    Flipper.enable(:target_advice_pages2025)
    sign_in(create(:school_admin, school:))
  end

  it_behaves_like 'it responds to HEAD requests'

  def visit_path(tab = nil)
    visit polymorphic_path([school, :"advice_#{fuel_type}_target"])
    click_on tab unless tab.nil?
  end

  context 'with no target' do
    it 'redirects to the new target page' do
      visit_path
      expect(page).to have_current_path("/schools/#{school.slug}/school_targets/new")
    end
  end

  def create_target(**kwargs)
    kwargs[:start_date] ||= Date.new(2024, 1, 1)
    create(:school_target, :with_monthly_consumption, **kwargs, school:, fuel_type:)
  end

  def fuel_string
    fuel_type.to_s.humanize(capitalize: false)
  end

  context 'with the Insights tab' do
    target_shared_examples('Insights')

    it 'says when there is not enough data' do
      create(:school_target, school:)
      visit_path('Insights')
      expect(page).to have_content('Not enough data to run analysis')
    end

    it 'has relevant content' do
      create_target
      visit_path('Insights')
      expect(page).to have_content <<~CONTENT
        What is your target?
        Setting a target to reduce your #{fuel_string} use gives you a goal to work towards. Following our advice and recommendations can help you achieve your target
        Your school has set a target to reduce its #{fuel_string} by 4&percnt; before January 2025
        Your current progress
        Back to top
        Unfortunately you are not meeting your target to reduce your #{fuel_string} usage
        Revise your target
        Period Cumulative consumption Target consumption % Change 01 Jan 2024 - 31 Dec 2024 12,120 12,000 0&percnt;
      CONTENT
    end
  end

  context 'with the Analysis tab' do
    target_shared_examples('Analysis')

    def expected_content(extra_contents)
      <<~CONTENT
        What is your target?
        Unfortunately you are not meeting your target to reduce your #{fuel_string} usage
        Monthly progress Cumulative progress#{extra_contents}
        Monthly progress
        Back to top
        Month Last year (kWh) Target (kWh) This year (kWh) % change On target? \
        January 2024 1,020 1,000 1,010 0&percnt; \
        February 2024 1,020 1,000 1,010 0&percnt; \
        March 2024 1,020 1,000 1,010 0&percnt; \
        April 2024 1,020 1,000 1,010 0&percnt; \
        May 2024 1,020 1,000 1,010 0&percnt; \
        June 2024 1,020 1,000 1,010 0&percnt; \
        July 2024 1,020 1,000 1,010 0&percnt; \
        August 2024 1,020 1,000 1,010 0&percnt; \
        September 2024 1,020 1,000 1,010 0&percnt; \
        October 2024 1,020 1,000 1,010 0&percnt; \
        November 2024 1,020 1,000 1,010 0&percnt; \
        December 2024 1,020 1,000 1,010 0&percnt;
        Partial months are shown in red.
        Cumulative progress
        Back to top
        Month Last year (kWh) Target (kWh) This year (kWh) % change On target? \
        January 2024 1,020 1,000 1,010 0&percnt; \
        February 2024 2,040 2,000 2,020 0&percnt; \
        March 2024 3,060 3,000 3,030 0&percnt; \
        April 2024 4,080 4,000 4,040 0&percnt; \
        May 2024 5,100 5,000 5,050 0&percnt; \
        June 2024 6,120 6,000 6,060 0&percnt; \
        July 2024 7,140 7,000 7,070 0&percnt; \
        August 2024 8,160 8,000 8,080 0&percnt; \
        September 2024 9,180 9,000 9,090 0&percnt; \
        October 2024 10,200 10,000 10,100 0&percnt; \
        November 2024 11,220 11,000 11,110 0&percnt; \
        December 2024 12,240 12,000 12,120 0&percnt;
        Partial months are shown in red.
      CONTENT
    end

    it 'has relevant content' do
      create_target
      visit_path('Analysis')
      expect(page).to have_content(expected_content(''))
    end

    it 'shows correct content with previous targets' do
      create_target
      create_target(start_date: Date.new(2023, 1, 1))
      create_target(start_date: Date.new(2022, 1, 1))
      visit_path('Analysis')

      expect(page).to have_content(expected_content(' Historical progress') + <<~CONTENT)
        Historical progress
        Back to top
        The following table shows your previous progress towards reducing your #{fuel_type} usage
        Target date Previous year (kWh) Target year (kWh) % change \
        January 2023 12,240 12,120 0&percnt; \
        January 2022 12,240 12,120 0&percnt;
      CONTENT
      # debugger
    end
  end
end
