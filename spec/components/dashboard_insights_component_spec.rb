# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DashboardInsightsComponent, :include_url_helpers, type: :component do
  subject(:component) { described_class.new(**params) }

  let(:school) { create(:school) }
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:progress_summary) { nil }
  let(:user) { create(:school_admin, school: school) }
  let(:audience) { :adult }
  let(:params) do
    {
      school: school,
      id: id,
      classes: classes,
      progress_summary: progress_summary,
      user: user,
      audience: audience
    }
  end

  let(:html) { render_inline(component) }

  it_behaves_like 'an application component' do
    let(:expected_classes) { classes }
    let(:expected_id) { id }
  end

  it { expect(html).to have_content(I18n.t('components.dashboard_insights.title')) }

  it 'displays the reminders column' do
    expect(html).to have_css('#adult-reminders')
    expect(html).to have_content(I18n.t('components.dashboard_insights.reminders.title'))
  end

  it 'does not display the alerts' do
    expect(html).to have_no_css('#adult-alerts')
  end

  context 'with alerts' do
    before do
      Flipper.enable :new_dashboards_2024 # alert component has conditional
    end

    include_context 'with dashboard alerts'

    it 'displays the alerts column' do
      expect(html).to have_css('#adult-alerts')
      expect(html).to have_content(I18n.t('advice_pages.index.alerts.title'))
    end

    it 'displays the alert text' do
      expect(html).to have_content('You can save £5,000 on heating in 1 year')
      expect(html).to have_content('Your baseload is high and is costing £5,000')
    end

    context 'with pupil audience' do
      let(:audience) { :pupil }

      it 'displays only the pupil alerts' do
        expect(html).to have_content('You can save £5,000 on heating in 1 year')
        expect(html).to have_no_content('Your baseload is high and is costing £5,000')
      end
    end

    context 'with Welsh locale' do
      around do |example|
        I18n.with_locale :cy do
          example.run
        end
      end

      it 'displays the alert text' do
        expect(html).to have_content('Gallwch arbed £7,000 mewn 1 flwyddyn')
      end
    end

    context 'when school is not data enabled' do
      let(:school) { create(:school, data_enabled: false) }

      it 'does not display the alerts' do
        expect(html).to have_no_css('#adult-alerts')
      end

      context 'with an admin' do
        let(:user) { create(:admin) }

        it 'displays the alerts' do
          expect(html).to have_css('#adult-alerts')
        end
      end
    end
  end

  context 'with a target progress summary' do
    before do
      Flipper.enable :new_dashboards_2024 # alert component has conditional
    end

    let!(:school_target)   { create(:school_target, school: school) }
    let(:progress_summary) { build(:progress_summary, school_target: school_target) }

    it 'displays the prompt' do
      expect(html).to have_css('#adult-alerts')
      expect(html).to have_content('Well done, you are making progress towards achieving your target')
    end

    it 'links to target page' do
      expect(html).to have_link('Review progress', href: school_school_targets_path(school))
    end

    context 'when one fuel is failing' do
      let(:progress_summary) { build(:progress_summary_with_failed_target, school_target: school_target) }

      it 'displays the correct prompts' do
        expect(html).to have_content('Unfortunately you are not meeting your target to reduce your gas usage')
        expect(html).to have_content('Well done, you are making progress towards achieving your target to reduce your electricity and storage heater usage')
      end
    end

    context 'when target has expired' do
      let!(:school_target) do
        create(:school_target, school: school, start_date: 1.year.ago, target_date: Date.yesterday)
      end
      let(:progress_summary) { build(:progress_summary, school_target: school_target) }

      it 'does not display a prompt' do
        expect(html).to have_no_content('Well done, you are making progress towards achieving your target')
      end
    end

    context 'with lagging data' do
      let(:electricity_progress) { build(:fuel_progress, recent_data: false) }
      let(:progress_summary) do
        build(:progress_summary, electricity: electricity_progress, school_target: school_target)
      end

      it 'displays a notice for the other fuel types' do
        expect(html).to have_no_content('Unfortunately you are not meeting your target')
        expect(html).to have_content('Well done, you are making progress towards achieving your target to reduce your gas and storage heater usage')
      end
    end

    context 'when school is not data enabled' do
      let(:school) { create(:school, data_enabled: false) }

      it 'does not display the alerts' do
        expect(html).to have_no_css('#adult-alerts')
      end
    end
  end

  context 'with a target monthly summary' do
    before do
      Flipper.enable(:target_advice_pages2025)
    end

    def div_text
      html.css('div').last.text.strip.gsub(/  +/, '')
    end

    it 'displays a negative electricity prompt' do
      create(:school_target, :with_monthly_consumption, school:)
      expect(div_text).to eq(
        "Unfortunately you are not meeting your target to reduce your electricity usage\n\n\nReview progress"
      )
      expect(html).to have_link('Review progress', href: "/schools/#{school.slug}/advice/electricity_target")
    end

    it 'displays a positive gas prompt' do
      create(:school_target, :with_monthly_consumption, school:, fuel_type: :gas, actual: 1000)
      expect(div_text).to eq(
        "Well done, you are making progress towards achieving your target to reduce your gas usage!\n\n\n" \
        'Review progress'
      )
      expect(html).to have_link('Review progress', href: "/schools/#{school.slug}/advice/gas_target")
    end
  end
end
