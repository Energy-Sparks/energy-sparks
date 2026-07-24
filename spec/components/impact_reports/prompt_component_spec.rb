# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImpactReports::PromptComponent, :include_application_helper,
               :include_url_helpers, type: :component do
  include ActionView::Helpers::SanitizeHelper

  let!(:school_group) { create(:school_group) }
  let!(:run) { create(:impact_report_run, visible_schools: 3, school_group:) } # rubocop:disable RSpec/LetSetup
  let!(:config) { create(:impact_report_configuration, school_group:, visible: true) } # rubocop:disable RSpec/LetSetup

  context with_feature: :impact_reporting do
    before do
      render_inline(described_class.new(school_group: school_group))
    end

    it 'has a title' do
      expect(page).to have_text 'Latest impact report'
    end

    it 'has a description' do
      group_type = I18n.t(school_group.group_type, scope: 'school_groups.clusters.group_type')
      expect(page).to have_text(strip_tags(
                                  I18n.t('school_groups.impact.feature.description_html',
                                         count: 3, group_type: group_type)
                                ))
    end

    it 'has button' do
      expect(page).to have_link('View impact report', href: school_group_impact_index_path(school_group))
    end

    context 'when report is not visible' do
      let(:config) { create(:impact_report_configuration, school_group:, visible: false) }

      it 'does not render' do
        expect(rendered_content).to be_blank
      end
    end

    context 'when not enough schools' do
      let(:run) do
        create(:impact_report_run, visible_schools: 1)
      end

      it 'does not render' do
        expect(rendered_content).to be_blank
      end
    end
  end

  context without_feature: :impact_reporting do
    before do
      render_inline(described_class.new(school_group: school_group))
    end

    it 'does not render' do
      expect(rendered_content).to be_blank
    end
  end
end
