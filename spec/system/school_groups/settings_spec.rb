# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'school group settings', :include_application_helper, :school_groups do
  let!(:setup_data) {} # hook for dashboard messages - goes before page is loaded
  let!(:school_group) { create(:school_group, :with_grouping) }
  let!(:user) { create(:admin) }

  before do
    Flipper.enable :group_settings
    Flipper.enable :school_group_secr_report

    sign_in(user)
    visit settings_school_group_path(school_group)
  end

  describe 'Dashboard message panel' do
    it_behaves_like 'admin dashboard messages' do
      let(:messageable) { school_group }
    end
  end

  describe 'Settings section' do
    it 'has the title' do
      within('#settings-section') do
        expect(page).to have_content(I18n.t('common.settings'))
      end
    end

    it 'has charts link' do
      within('#settings-section') do
        expect(page).to have_content(I18n.t('common.charts'))
        expect(page).to have_link(
          I18n.t('common.labels.manage'),
          href: school_group_chart_updates_path(school_group)
        )
      end
    end

    it 'has clusters link' do
      within('#settings-section') do
        expect(page).to have_content(I18n.t('common.clusters'))
        expect(page).to have_link(
          I18n.t('common.labels.manage'),
          href: school_group_clusters_path(school_group)
        )
      end
    end

    it 'has tariffs link' do
      within('#settings-section') do
        expect(page).to have_content(I18n.t('common.tariffs'))
        expect(page).to have_link(
          I18n.t('common.labels.manage'),
          href: school_group_energy_tariffs_path(school_group)
        )
      end
    end
  end

  describe 'Schools section' do
    it 'has the title' do
      within('#schools-section') do
        expect(page).to have_content(I18n.t('common.schools'))
      end
    end

    it 'has digital signage link' do
      within('#schools-section') do
        expect(page).to have_content(I18n.t('manage_school_menu.digital_signage'))
        expect(page).to have_link(
          I18n.t('common.labels.view'),
          href: school_group_digital_signage_index_path(school_group)
        )
      end
    end

    it 'has engagement link' do
      within('#schools-section') do
        expect(page).to have_content(I18n.t('common.engagement'))
        expect(page).to have_link(
          I18n.t('common.labels.view'),
          href: school_group_school_engagement_index_path(school_group)
        )
      end
    end

    it 'has SECR report link' do
      within('#schools-section') do
        expect(page).to have_content(I18n.t('school_groups.sub_nav.secr_report'))
        expect(page).to have_link(
          I18n.t('common.labels.view'),
          href: school_group_secr_index_path(school_group)
        )
      end
    end

    it 'has timeline link' do
      within('#schools-section') do
        expect(page).to have_content(I18n.t('common.timeline'))
        expect(page).to have_link(
          I18n.t('common.labels.manage'),
          href: school_group_timeline_path(school_group)
        )
      end
    end
  end
end
