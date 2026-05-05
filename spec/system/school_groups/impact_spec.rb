# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'school group impact reports', :include_application_helper, :school_groups do
  include ActionView::Helpers::SanitizeHelper

  let!(:school_group) { create(:school_group, :with_active_schools, count: 2, public: true) }
  let!(:config) { create(:impact_report_configuration, school_group:, visible: true) }

  before do
    # so we can display a testimonial
    create(:testimonial, case_study: create(:case_study, organisation: school_group))
  end

  describe 'Access control' do
    shared_examples 'an access controlled impact page' do |message: 'This feature is not available'|
      it 'redirects to school group dashboard' do
        expect(page).to have_current_path(school_group_path(school_group))
        expect(page).to have_content(message)
      end
    end

    context without_feature: :impact_reporting do
      before do
        visit school_group_impact_index_path(school_group)
      end

      it_behaves_like 'an access controlled impact page'
    end

    context with_feature: :impact_reporting do
      it_behaves_like 'an access controlled group page', with_schools_check: false do
        let(:path) { school_group_impact_index_path(school_group) }
      end

      let(:user) { nil }

      before do
        login_as(user) if user.present?
        visit school_group_impact_index_path(school_group)
      end

      context 'when there is no config and user is not logged in' do
        let(:config) { nil }
        let(:user) { nil }

        it_behaves_like 'an access controlled impact page'
      end

      context 'when config is not visible' do
        let!(:config) { create(:impact_report_configuration, school_group:, visible: false) }

        it_behaves_like 'an access controlled impact page'
      end

      context 'when config is visible but user is not admin' do
        let!(:config) { create(:impact_report_configuration, school_group:, visible: false) }
        let(:user) { create(:group_admin, school_group:) }

        it_behaves_like 'an access controlled impact page'
      end

      context 'when config is visible and user is an admin' do
        let!(:config) { create(:impact_report_configuration, school_group:, visible: false) }
        let(:user) { create(:admin) }

        it 'allows access' do
          expect(page).to have_current_path(school_group_impact_index_path(school_group))
        end
      end

      context 'when group has less than 2 schools' do
        let!(:school_group) { create(:school_group, :with_active_schools, count: 1, public: true) }

        it_behaves_like 'an access controlled impact page', message: 'Not enough data'
      end
    end
  end

  describe 'Page layout' do
    before do
      Flipper.enable(:impact_reporting)

      school = school_group.schools.first
      school.update(scoreboard: create(:scoreboard))
      create(:activity, school: school)

      # so we can show a testimonial
      create(:testimonial)

      # so we can show an energy efficiency featured school
      config.update(energy_efficiency_school: school_group.schools.first, energy_efficiency_note: 'Super school')

      visit school_group_impact_index_path(school_group)
    end

    describe 'Header section' do
      let(:header) { find_by_id('header-section') }

      it 'has the title' do
        expect(header).to have_content("#{school_group.name} Impact Report")
      end

      it 'has the description' do
        group_type = I18n.t(school_group.group_type, scope: 'school_groups.clusters.group_type')
        expect(header).to have_content(strip_tags(
                                         I18n.t('school_groups.impact.feature.description_html',
                                                count: 2,
                                                group_type: group_type)
                                       ))
      end

      it 'has the report generation date' do
        expect(header).to have_content(strip_tags(I18n.t('common.last_updated_on_html',
                                                         date: Time.zone.today.to_date.to_fs(:es_long))))
      end

      it 'has the read more link' do
        expect(header).to have_content(strip_tags(I18n.t('school_groups.impact.feature.read_more_html',
                                                         href: '#notes')))
        expect(header).to have_link('Read more', href: '#notes')
      end
    end

    describe 'Page body' do
      it { expect(page).to have_css('#overview-header') }
      it { expect(page).to have_css('#overview-cards') }
      it { expect(page).to have_css('#overview-testimonials') }

      it { expect(page).to have_css('#energy-efficiency-header') }
      it { expect(page).to have_css('#energy-efficiency-cards') }
      it { expect(page).to have_css('#energy-efficiency-featured') }
      it { expect(page).to have_css('#energy-efficiency-buttons') }

      it { expect(page).to have_css('#engagement-header') }
      it { expect(page).to have_css('#engagement-cards') }
      it { expect(page).to have_css('#engagement-featured') }
      it { expect(page).to have_css('#engagement-buttons') }

      it { expect(page).to have_css('#potential-savings-header') }
      it { expect(page).to have_css('#potential-savings-cards') }
      it { expect(page).to have_css('#potential-savings-button') }

      it { expect(page).to have_css('#notes') }
      it { expect(page).to have_css('#notes-content') }
    end
  end
end
