# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Navigation::AdminActivitiesComponent, :include_url_helpers, type: :component do
  context 'when rendering' do
    before do
      render_inline(described_class.new)
    end

    it { expect(page).to have_link('Overview', href: admin_activities_root_path) }

    describe 'activities section' do
      it { expect(page).to have_link('Activities', href: admin_activity_types_path) }
      it { expect(page).to have_link('Categories', href: admin_activity_categories_path) }
      it { expect(page).to have_link('Classifications', href: admin_activities_labels_path(label_type: 'aim')) }
      it { expect(page).to have_link('Latest Recordings', href: admin_reports_activities_path) }
      it { expect(page).to have_link('Report', href: admin_reports_activity_types_path) }
    end

    describe 'actions section' do
      it { expect(page).to have_link('Actions', href: admin_intervention_types_path) }
      it { expect(page).to have_link('Categories', href: admin_intervention_type_groups_path) }
      it { expect(page).to have_link('Classifications', href: admin_activities_labels_path(label_type: 'focus')) }
      it { expect(page).to have_link('Latest Recordings', href: admin_reports_interventions_path) }
      it { expect(page).to have_link('Report', href: admin_reports_intervention_types_path) }
    end

    describe 'related section' do
      it { expect(page).to have_link('Advice pages', href: admin_advice_pages_path) }
      it { expect(page).to have_link('Alerts', href: admin_alert_types_path) }
      it { expect(page).to have_link('Audits', href: admin_reports_recent_audits_path) }
      it { expect(page).to have_link('Programmes', href: admin_programme_types_path) }
      it { expect(page).to have_link('Recent images', href: admin_reports_images_path) }
    end
  end
end
