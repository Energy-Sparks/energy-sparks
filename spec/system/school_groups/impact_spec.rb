# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'school group impact reports', :include_application_helper, :school_groups do
  include ActionView::Helpers::SanitizeHelper

  let!(:school_group) { create(:school_group, :with_active_schools, public: true) }

  # TODO: Test page access control - currently uses SchoolGroupAccessControl
  # Question: What if there are 0 schools in the group? redirect away?
  # Not even generate report data record in the first place?

  context with_feature: :impact_reporting do
    before do
      visit school_group_impact_index_path(school_group)
    end

    describe 'Header section' do
      let(:header) { find('#header-section') }

      it 'has the title' do
        expect(header).to have_content("#{school_group.name} Impact Report")
      end

      it 'has the description' do
        group_type = I18n.t(school_group.group_type, scope: 'school_groups.clusters.group_type')
        expect(header).to have_content(strip_tags(I18n.t('school_groups.impact.feature.description_html', count: 1, group_type: group_type)))
      end

      it 'has the report generation date' do
        expect(header).to have_content(strip_tags(I18n.t('common.last_updated_on_html', date: Time.zone.today.to_date.to_fs(:es_long))))
      end

      it 'has the read more link' do
        expect(header).to have_content(strip_tags(I18n.t('school_groups.impact.feature.read_more_html', href: '/')))
        expect(header).to have_link('Read more', href: '/') # TODO: LINK NEEDS UPDATING
      end
    end
  end

  context without_feature: :impact_reporting do
    before do
      visit school_group_impact_index_path(school_group)
    end

    it 'redirects to the group page' do
      expect(page).to have_current_path(school_group_path(school_group))
    end
  end
end
