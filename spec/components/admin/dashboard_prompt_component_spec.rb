#  frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::DashboardPromptComponent, :include_application_helper, :include_url_helpers, type: :component do
  let!(:user) { create(:admin) }

  describe 'overdue issues prompt' do
    context 'when there are no overdue issues' do
      before do
        render_inline described_class.new(user: user)
      end

      it 'does not display the overdue issues prompt' do
        expect(page).to have_no_text('issues overdue')
      end
    end

    context 'when there are overdue issues' do
      before do
        create_list(:issue, 2, owned_by: user, review_date: Date.current - 2)
        render_inline described_class.new(user: user)
      end

      it 'displays the overdue issues prompt' do
        expect(page).to have_text('You have 2 issues overdue for review')
        expect(page).to have_link('View Issues',
                                  href: admin_dashboard_issues_path(dashboard_id: user,
                                                                    user: user.id,
                                                                    review_date: 'review_overdue'))
      end
    end
  end

  describe 'weekly issues prompt' do
    context 'when there are no issues due in the coming week' do
      before do
        render_inline described_class.new(user: user)
      end

      it 'does not display the weekly issues prompt' do
        expect(page).to have_no_text('review in the next week')
      end
    end

    context 'when there are issues due in the coming week' do
      before do
        create_list(:issue, 2, owned_by: user, review_date: Date.current + 2)
        render_inline described_class.new(user: user)
      end

      it 'displays the weekly issues prompt' do
        expect(page).to have_text('You have 2 issues due for review in the next week')
        expect(page).to have_link('View Issues',
                                  href: admin_dashboard_issues_path(dashboard_id: user,
                                                                    user: user.id,
                                                                    review_date: 'review_next_week'))
      end
    end
  end

  describe 'school activation prompt' do
    context 'when no schools are awaiting activation' do
      before do
        render_inline described_class.new(user: user)
      end

      it 'does not display the school activation prompt' do
        expect(page).to have_no_text('schools awaiting activation')
      end
    end

    context 'when there are schools awaiting activation' do
      before do
        create(:school, school_group: create(:school_group, default_issues_admin_user: user), active: true,
                        visible: false, data_enabled: false)
        render_inline described_class.new(user: user)
      end

      it 'displays the school activation prompt' do
        expect(page).to have_text('You have 1 schools awaiting activation')
        expect(page).to have_link('Activations', href: admin_activations_path)
      end
    end
  end

  describe 'lagging data source prompt' do
    context 'when there are no lagging data sources' do
      before do
        render_inline described_class.new(user: user)
      end

      it 'does not display the lagging data sources prompt' do
        expect(page).to have_no_text('lagging data sources')
      end
    end

    context 'when there are lagging data sources' do
      before do
        create(:gas_meter_with_validated_reading_dates, end_date: 11.days.ago,
                                                        data_source: create(:data_source, owned_by: user))
        render_inline described_class.new(user: user)
      end

      it 'displays the lagging data sources prompt' do
        expect(page).to have_text('You have 1 lagging data sources')
        expect(page).to have_link('View Data Sources', href: admin_dashboard_data_sources_path(dashboard_id: user))
      end
    end
  end

  describe 'missing data feeds prompt' do
    context 'when there are no data feeds with missing data' do
      before do
        render_inline described_class.new(user: user)
      end

      it 'does not display the missing data feeds prompt' do
        expect(page).to have_no_text('configurations with missing data')
      end
    end

    context 'when there are data feeds with missing data' do
      let(:config) { create(:amr_data_feed_config, owned_by: user, missing_reading_window: 2) }

      before do
        create(
          :amr_data_feed_reading,
          amr_data_feed_config: config,
          reading_date: 4.days.ago,
          updated_at: 4.days.ago
        )
        render_inline described_class.new(user: user)
      end

      it 'displays the missing data feeds prompt' do
        expect(page).to have_text('You have 1 amr data feed configurations with missing data')
        expect(page).to have_link('View AMR Data Feed Configurations',
                                  href: admin_dashboard_amr_data_feed_configs_path(dashboard_id: user))
      end
    end
  end

  describe 'school onboarding prompt' do
    context 'when there are no schools onboarding' do
      before do
        render_inline described_class.new(user: user)
      end

      it 'does not display the school onboarding prompt' do
        expect(page).to have_no_text('schools that have not yet completed onboarding')
      end
    end

    context 'when there are schools onboarding' do
      let(:school_group) { create(:school_group, default_issues_admin_user: user) }

      before do
        create(:school_onboarding,
               :with_events,
               event_names: %i[email_sent],
               school_group_id: school_group.id)
        render_inline described_class.new(user: user)
      end

      it 'displays the school onboarding prompt' do
        expect(page).to have_text('You have 1 schools that have not yet completed onboarding')
        expect(page).to have_link('View Onboardings', href: admin_dashboard_school_onboardings_path(dashboard_id: user))
      end
    end
  end
end
