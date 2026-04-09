# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::DashboardPromptComponent, :include_url_helpers, type: :component do
  subject(:component) do
    described_class.new(user:)
  end

  let(:user) { create(:admin) }

  context 'when rendering' do
    let(:html) do
      render_inline(component)
    end

    describe 'overdue issues prompt' do
      context 'when there are no overdue issues' do
        it 'does not display the overdue issues prompt' do
          expect(html).to have_no_css('#overdue-issues')
        end
      end

      context 'when there are overdue issues' do
        before do
          create_list(:issue, 2, owned_by: user, review_date: Date.current - 2)
        end

        it 'displays the overdue issues prompt' do
          expect(html).to have_css('#overdue-issues')
          expect(html).to have_text('You have 2 issues overdue for review')
          expect(html).to have_link('View Issues', href: admin_issues_path(user: user.id))
        end
      end
    end

    describe 'weekly issues prompt' do
      context 'when there are no issues due in the coming week' do
        it 'does not display the weekly issues prompt' do
          expect(html).to have_no_css('#weekly-issues')
        end
      end

      context 'when there are issues due in the coming week' do
        before do
          create_list(:issue, 2, owned_by: user, review_date: Date.current + 2)
        end

        it 'displays the weekly issues prompt' do
          expect(html).to have_css('#weekly-issues')
          expect(html).to have_text('You have 2 issues due for review in the next week')
          expect(html).to have_link('View Issues', href: admin_issues_path(user: user.id))
        end
      end
    end

    describe 'school activation prompt' do
      context 'when no schools are awaiting activation' do
        it 'does not display the school activation prompt' do
          expect(html).to have_no_css('#school-activation')
        end
      end

      context 'when there are schools awaiting activation' do
        before do
          create(:school, school_group: create(:school_group, default_issues_admin_user: user), active: true,
                          visible: false, data_enabled: false)
        end

        it 'displays the school activation prompt' do
          expect(html).to have_css('#school-activation')
          expect(html).to have_text('You have 1 schools awaiting activation')
          expect(html).to have_link('Activations', href: admin_activations_path)
        end
      end
    end

    describe 'lagging data source prompt' do
      context 'when there are no lagging data sources' do
        it 'does not display the lagging data sources prompt' do
          expect(html).to have_no_css('#lagging-data-sources')
        end
      end

      context 'when there are lagging data sources' do
        before do
          create(:gas_meter_with_validated_reading_dates, end_date: 11.days.ago,
                                                          data_source: create(:data_source, owned_by: user))
        end

        it 'displays the lagging data sources prompt' do
          expect(html).to have_css('#lagging-data-sources')
          expect(html).to have_text('You have 1 lagging data sources')
          expect(html).to have_link('View Data Sources', href: admin_data_sources_path)
        end
      end
    end

    describe 'missing data feeds prompt' do
      context 'when there are no data feeds with missing data' do
        it 'does not display the missing data feeds prompt' do
          expect(html).to have_no_css('#missing-data-feeds')
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
        end

        it 'displays the missing data feeds prompt' do
          expect(html).to have_css('#missing-data-feeds')
          expect(html).to have_text('You have 1 amr data feed configurations with missing data')
          expect(html).to have_link('Import Logs', href: admin_reports_amr_data_feed_import_logs_path)
        end
      end
    end
  end
end
