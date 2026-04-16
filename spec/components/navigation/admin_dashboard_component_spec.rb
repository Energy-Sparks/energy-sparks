# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Navigation::AdminDashboardComponent, :include_url_helpers, type: :component do
  subject(:component) do
    described_class.new(**params)
  end

  let(:current_user) { create(:admin) }

  let(:params) do
    { current_user: }
  end

  context 'when rendering' do
    let(:html) do
      render_inline(component)
    end

    it { expect(html).to have_link('Dashboard Home', href: admin_dashboard_path(current_user)) }

    describe 'my x links' do
      it 'has the correct links' do
        expect(html).to have_link('My School Groups',
                                  href: admin_dashboard_school_groups_path(current_user))
        expect(html).to have_link('My Project Groups',
                                  href: admin_dashboard_school_groups_path(current_user, group_type: 'project'))
        expect(html).to have_link('My Data Sources',
                                  href: admin_dashboard_data_sources_path(current_user))
        expect(html).to have_link('My Data Feeds',
                                  href: admin_dashboard_amr_data_feed_configs_path(current_user))
        expect(html).to have_link('My Issues',
                                  href: admin_dashboard_issues_path(current_user))
      end
    end
  end
end
