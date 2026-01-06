# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Navigation::ManageGroupComponent, :include_application_helper, :include_url_helpers, type: :component do
  subject(:component) do
    described_class.new(**params)
  end

  let(:school_group) { create(:school_group) }
  let(:current_user) { create(:admin) }

  let(:params) do
    { school_group: school_group, current_user: current_user, classes: 'extra-classes' }
  end

  shared_examples 'a correctly populated settings section' do
    it 'has the correct links' do
      within('#settings') do
        expect(html).to have_link(I18n.t('common.charts'),
                                  href: school_group_chart_updates_path(school_group))
        expect(html).to have_link(I18n.t('common.clusters'),
                                  href: school_group_clusters_path(school_group))
        expect(html).to have_link(I18n.t('common.tariffs'),
                                  href: school_group_energy_tariffs_path(school_group))
      end
    end
  end

  shared_examples 'a correctly populated schools section' do
    it 'has the correct links' do
      within('#schools') do
        expect(html).to have_link(I18n.t('manage_school_menu.digital_signage'),
                                  href: school_group_digital_signage_index_path(school_group))
        expect(html).to have_link(I18n.t('common.engagement'),
                                  href: school_group_school_engagement_index_path(school_group))
        expect(html).to have_link(I18n.t('school_groups.sub_nav.secr_report'),
                                  href: school_group_secr_index_path(school_group))
        expect(html).to have_link(I18n.t('common.labels.settings'),
                                  href: status_school_group_path(school_group))
        expect(html).to have_link(I18n.t('common.timeline'),
                                  href: school_group_timeline_path(school_group))
      end
    end
  end

  shared_examples 'a correctly populated admin section' do
    it 'has the correct links' do
      within('#admin') do
        expect(html).to have_link(I18n.t('school_groups.sub_nav.edit_group'),
                                  href: edit_admin_school_group_path(school_group))
        expect(html).to have_link(I18n.t('school_groups.sub_nav.group_admin'),
                                  href: admin_school_group_path(school_group))
        expect(html).to have_link('Issues',
                                  href: admin_school_group_issues_path(school_group))
        expect(html).to have_link(I18n.t('school_groups.sub_nav.manage_users'),
                                  href: admin_school_group_users_path(school_group))
        expect(html).to have_link(I18n.t('school_groups.sub_nav.manage_partners'),
                                  href: admin_school_group_partners_path(school_group))
      end
    end
  end

  context 'when rendering' do
    let(:html) do
      render_inline(component)
    end

    context 'with settings section' do
      it 'has the title section' do
        expect(html).to have_content(I18n.t('common.settings'))
      end

      it_behaves_like 'a correctly populated settings section'
    end

    context 'with schools section' do
      it 'has the title section' do
        expect(html).to have_content(I18n.t('common.schools'))
      end

      it_behaves_like 'a correctly populated schools section'
    end

    context 'with admin section' do
      it 'has the admin section' do
        expect(html).to have_content(I18n.t('common.admin'))
      end

      it_behaves_like 'a correctly populated admin section'
    end
  end
end
