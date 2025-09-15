# frozen_string_literal: true

require 'rails_helper'

def target_shared_examples(tab)
  context 'with shared examples' do
    before do
      create(:school_target, :with_monthly_consumption, school:, fuel_type:)
      visit_tab(tab)
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
  end

  it_behaves_like 'it responds to HEAD requests'

  def visit_tab(tab, sign_in: true)
    sign_in(create(:school_admin, school:)) if sign_in
    visit polymorphic_path([school, :"advice_#{fuel_type}_target"])
    click_on tab unless tab.nil?
  end

  context 'with no target' do
    it 'redirects to the new target page' do
      visit_tab(nil)
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

  def content(name)
    find("##{fuel_type}_target-#{name.downcase}").text.gsub(/^How have we analysed your data?.*/m, '')
  end

  def limited_data_content
    <<~CONTENT.chomp
      Limited historical data
      We have limited historical data for your school so are unable to calculate a progress report to help you track progress towards completing your target.
      If we are able to access historical data for your school then a report will automatically become available.
      #{if fuel_type == :storage_heater
          'In the meantime you can learn more about this topic.'
        else
          'In the meantime you can monitor your usage using the charts on the ' \
            "long term #{fuel_type} usage advice page"
        end}
    CONTENT
  end

  def waiting_for_data_text
    'You have reached your target date but we are still waiting for more data ' \
      'to complete your final progress report. You can set a new target now or ' \
      "wait for your progress report to be complete.\n"
  end

  context 'with the Insights tab' do
    let(:tab) { 'Insights' }

    target_shared_examples('Insights')

    def insight_content(expired: true, can_revise: false, expired_text: nil, table_text: nil, meeting_prompt: true)
      <<~CONTENT
        #{expired_text}\
        #{"You have reached your target date and is it complete. You can set a new target now.\n" if expired
        }What is your target?
        Setting a target to reduce your #{fuel_string} use gives you a goal to work towards. Following our advice and recommendations can help you achieve your target.
        Your school has set a target to reduce its #{fuel_string} by 4&percnt; before January 2025.
        #{"You can revise your target.\n" if can_revise}Learn more
        Your current progress
        Back to top
        #{"Unfortunately you are not meeting your target to reduce your #{fuel_string} usage\n" if meeting_prompt
        }Period Cumulative consumption (kWh) Target consumption (kWh) % Change \
        #{table_text || '01 Jan 2024 - 31 Dec 2024 12,120 12,000 +1&percnt;'}
        How did we calculate these figures?
        #{if fuel_type == :storage_heater
            'View your detailed progress report.'
          else
            'View your detailed progress report or compare progress with other schools in your group.'
          end}
        What should you do next?
        Back to top
      CONTENT
    end

    it 'has relevant content' do
      create_target
      visit_tab(tab)
      expect(content(tab)).to eq(insight_content)
    end

    it 'new target with no consumption' do
      create(:school_target, school:)
      visit_tab(tab)
      expect(content(tab)).to have_content(<<~CONTENT.chomp)
        Waiting to process data for your new target
        Data for your new target should be available tomorrow.
        In the meantime you can learn more about this topic.
      CONTENT
    end

    it 'target in future' do
      create_target(start_date: 1.day.from_now)
      visit_tab(tab)
      expect(content(tab)).to \
        have_content('Target date is in the future so no consumption has yet been recorded.')
    end

    it 'missing previous years data' do
      create_target(target_consumption: nil, missing: true)
      visit_tab(tab)
      expect(content(tab)).to eq(limited_data_content)
    end

    it 'non expired target' do
      target = create_target
      travel_to(target.start_date + 6.months)
      visit_tab(tab)
      expect(content(tab)).to eq(insight_content(expired: false, can_revise: true))
    end

    context 'with target not set' do
      before { create(:school_target, school:, fuel_type => nil) }

      def not_set_content(revise_text)
        <<~CONTENT.chomp
          No target set
          Your school has not set a target for #{fuel_string} use so we can't generate a progress report.
          #{revise_text}
          In the meantime you can learn more about this topic.
        CONTENT
      end

      it 'signed in' do
        visit_tab(tab)
        expect(content(tab)).to eq(not_set_content('You can revise your target.'))
      end

      it 'guest' do
        visit_tab(tab, sign_in: false)
        expect(content(tab)).to eq(not_set_content('You need to login to set a target.'))
      end
    end

    it 'target not yet complete' do
      create_target(missing: ([false] * 11) + [true])
      visit_tab(tab)
      expect(content(tab)).to \
        eq(insight_content(expired_text: waiting_for_data_text,
                           expired: false,
                           table_text: '01 Jan 2024 - 30 Nov 2024 11,110 11,000 +1&percnt;'))
    end

    context 'with out recent data' do
      let(:school) do
        create(:school, :with_fuel_configuration, :with_meter_dates, reading_end_date: 30.days.ago, fuel_type:)
      end

      it 'has relevant content' do
        create_target
        visit_tab(tab)
        expect(content(tab)).to \
          eq(insight_content(expired_text: "We have not received data for your #{fuel_string} usage for over thirty " \
                                           'days. As a result your analysis will be out of date and may not reflect ' \
                                           "recent changes in your school.\n",
                             table_text: '01 Jan 2024 - 31 Dec 2024',
                             meeting_prompt: false))
      end
    end
  end

  context 'with the Analysis tab' do
    let(:tab) { 'Analysis' }

    target_shared_examples('Analysis')

    def expected_content(extra_contents = '', year = 2024)
      <<~CONTENT
        Progress report
        The following sections provide more detailed analysis of your school's #{fuel_string} target throughout the target period.
        Monthly progress Cumulative progress#{extra_contents}
        Unfortunately you are not meeting your target to reduce your #{fuel_string} usage
        Monthly progress
        Back to top
        This table summarises your progress to reduce your #{fuel_string} use by 4&percnt; on a month by month basis. Each entry in the table shows the target and actual consumption for every month in the target period. This table can be helpful in identifying which months have you have made the most savings or where your energy use has exceeded the target.
        Month Last year (kWh) Target (kWh) This year (kWh) % change On target? \
        January #{year} 1,020 1,000 1,010 +1&percnt; \
        February #{year} 1,020 1,000 1,010 +1&percnt; \
        March #{year} 1,020 1,000 1,010 +1&percnt; \
        April #{year} 1,020 1,000 1,010 +1&percnt; \
        May #{year} 1,020 1,000 1,010 +1&percnt; \
        June #{year} 1,020 1,000 1,010 +1&percnt; \
        July #{year} 1,020 1,000 1,010 +1&percnt; \
        August #{year} 1,020 1,000 1,010 +1&percnt; \
        September #{year} 1,020 1,000 1,010 +1&percnt; \
        October #{year} 1,020 1,000 1,010 +1&percnt; \
        November #{year} 1,020 1,000 1,010 +1&percnt; \
        December #{year} 1,020 1,000 1,010 +1&percnt;
        Partial months are shown in red. How did we calculate these figures?
        Cumulative progress
        Back to top
        This table summarises your overall progress towards reducing your #{fuel_string} use by 4&percnt;. Each entry in the table shows the cumulative target and consumption for each month in the target period. This table help you to monitor whether you are on track to achieve the target by January #{year + 1}.
        Month Last year (kWh) Target (kWh) This year (kWh) % change On target? \
        January #{year} 1,020 1,000 1,010 +1&percnt; \
        February #{year} 2,040 2,000 2,020 +1&percnt; \
        March #{year} 3,060 3,000 3,030 +1&percnt; \
        April #{year} 4,080 4,000 4,040 +1&percnt; \
        May #{year} 5,100 5,000 5,050 +1&percnt; \
        June #{year} 6,120 6,000 6,060 +1&percnt; \
        July #{year} 7,140 7,000 7,070 +1&percnt; \
        August #{year} 8,160 8,000 8,080 +1&percnt; \
        September #{year} 9,180 9,000 9,090 +1&percnt; \
        October #{year} 10,200 10,000 10,100 +1&percnt; \
        November #{year} 11,220 11,000 11,110 +1&percnt; \
        December #{year} 12,240 12,000 12,120 +1&percnt;
        Partial months are shown in red. How did we calculate these figures?
      CONTENT
    end

    it 'has relevant content' do
      create_target
      visit_tab(tab)
      expect(content(tab)).to eq(
        "You have reached your target date and is it complete. You can set a new target now.\n#{expected_content}"
      )
    end

    it 'shows correct content with previous targets' do
      travel_to(Date.new(2026, 1, 1))
      create_target(start_date: Date.new(2026, 1, 1))
      create_target(start_date: Date.new(2025, 1, 1))
      create_target(start_date: Date.new(2024, 1, 1),
                    "#{fuel_type}_progress": { 'usage' => 11_000, 'target' => 10_000 }, target: 5)
      visit_tab(tab)
      expect(content(tab)).to eq(expected_content(' Historical progress', 2026) + <<~CONTENT)
        Historical progress
        Back to top
        The following table shows your previous progress towards reducing your #{fuel_string} usage
        Target date Previous year (kWh) Target year (kWh) % change Target \
        January 2026 12,120 12,000 +1&percnt; 4&percnt; \
        January 2025 11,000 10,000 +10&percnt; 5&percnt;
      CONTENT
    end

    it 'new target with no consumption' do
      create(:school_target, school:)
      visit_tab(tab)
      expect(content(tab)).to eq(<<~CONTENT.chomp)
        Waiting to process data for your new target
        Data for your new target should be available tomorrow.
        In the meantime you can learn more about this topic.
      CONTENT
    end

    it 'target in future' do
      create_target(start_date: 1.day.from_now)
      visit_tab(tab)
      expect(content(tab)).to \
        have_content('Target date is in the future so no consumption has yet been recorded.')
    end

    it 'missing previous years data' do
      create_target(target_consumption: nil, previous_consumption: nil, missing: true)
      visit_tab(tab)
      expect(content(tab)).to eq(limited_data_content)
    end

    it 'target not yet complete' do
      create_target(missing: ([false] * 11) + [true])
      visit_tab(tab)
      expect(content(tab)).to start_with(waiting_for_data_text)
    end
  end
end

RSpec.describe 'target advice pages' do
  context 'with electricity' do
    it_behaves_like 'target advice page' do
      let(:fuel_type) { :electricity }
    end
  end

  context 'with gas' do
    it_behaves_like 'target advice page' do
      let(:fuel_type) { :gas }
    end
  end

  context 'with storage heater' do
    it_behaves_like 'target advice page' do
      let(:fuel_type) { :storage_heater }
    end
  end
end
