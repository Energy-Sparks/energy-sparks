# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DashboardInsightsComponent, :include_url_helpers, type: :component do
  subject(:component) { described_class.new(**params) }

  let(:school) { create(:school) }
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:user) { create(:school_admin, school: school) }
  let(:audience) { :adult }
  let(:params) do
    {
      school: school,
      id: id,
      classes: classes,
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

  context 'with a target monthly summary' do
    let(:school) { create(:school, :with_fuel_configuration, :with_meter_dates) }

    def div_text
      html.css('div').last.text.strip.gsub(/  +/, '')
    end

    context 'when electricity target failing' do
      before { create(:school_target, :with_monthly_consumption, school:) }

      it 'displays a negative electricity prompt' do
        expect(div_text).to eq(
          "Unfortunately you are not meeting your target to reduce your electricity usage\n\n\nReview progress"
        )
        expect(html).to have_link('Review progress', href: "/schools/#{school.slug}/advice/electricity_target")
      end
    end

    context 'with incomplete target data' do
      before do
        create(:school_target, :with_monthly_consumption, school:, current_missing: true)
      end

      it 'displays nothing' do
        expect(div_text).to eq('')
      end
    end

    context 'when gas target passing' do
      let(:school) { create(:school, :with_fuel_configuration, :with_meter_dates, fuel_type: :gas) }

      before { create(:school_target, :with_monthly_consumption, school:, fuel_type: :gas, current_consumption: 1000) }

      it 'displays a positive gas prompt' do
        expect(div_text).to eq(
          "Well done, you are making progress towards achieving your target to reduce your gas usage!\n\n\n" \
          'Review progress'
        )
        expect(html).to have_link('Review progress', href: "/schools/#{school.slug}/advice/gas_target")
      end
    end
  end
end
