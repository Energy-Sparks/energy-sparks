# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dashboards::GroupRemindersComponent, :include_application_helper, :include_url_helpers, type: :component do
  subject(:html) do
    render_inline(described_class.new(**params))
  end

  let(:user) { create(:admin) }
  let(:school_group) { create(:school_group) }

  let(:params) do
    {
      school_group: school_group,
      user: user,
      id: 'custom-id',
      classes: 'extra-classes'
    }
  end

  it_behaves_like 'an application component' do
    let(:expected_classes) { 'extra-classes' }
    let(:expected_id) { 'custom-id' }
  end

  describe '#prompt_for_training?' do
    context 'with admin user' do
      it { expect(html).not_to have_content(I18n.t('schools.show.find_training')) }
    end

    context 'with school admin' do
      let(:user) { create(:school_admin, school: create(:school, school_group: school_group)) }

      it { expect(html).not_to have_content(I18n.t('schools.show.find_training')) }
    end

    context 'with group admin from other group' do
      let(:user) { create(:group_admin) }

      it { expect(html).not_to have_content(I18n.t('schools.show.find_training')) }
    end

    context 'with the group admin' do
      let(:user) { create(:group_admin, school_group: school_group) }

      it { expect(html).to have_content(I18n.t('schools.show.find_training')) }
    end

    context 'with the group admin confirmed a while ago' do
      let(:user) { create(:group_admin, confirmed_at: 31.days.ago, school_group: school_group) }

      it { expect(html).not_to have_content(I18n.t('schools.show.find_training')) }
    end
  end

  context 'when showing dashboard messages' do
    let!(:dashboard_message) { create(:dashboard_message, messageable: school_group) }

    it { expect(html).to have_content(dashboard_message.message) }
  end

  describe '#prompt_for_clusters?' do
    context 'with admin user' do
      it { expect(html).to have_content(I18n.t('components.dashboards.group_reminders.clusters.note')) }
    end

    context 'with school admin' do
      let(:user) { create(:school_admin, school: create(:school, school_group: school_group)) }

      it { expect(html).not_to have_content(I18n.t('components.dashboards.group_reminders.clusters.note')) }
    end

    context 'with group admin from other group' do
      let(:user) { create(:group_admin) }

      it { expect(html).not_to have_content(I18n.t('components.dashboards.group_reminders.clusters.note')) }
    end

    context 'with the group admin' do
      let(:user) { create(:group_admin, school_group: school_group) }

      it { expect(html).to have_content(I18n.t('components.dashboards.group_reminders.clusters.note')) }
    end

    context 'with clusters' do
      before do
        create(:school_group_cluster, school_group: school_group)
      end

      context 'with the group admin' do
        let(:user) { create(:group_admin, school_group: school_group) }

        it { expect(html).not_to have_content(I18n.t('components.dashboards.group_reminders.clusters.note')) }
      end
    end
  end

  describe '#prompt_for_tariffs?' do
    context 'when in reminder period' do
      before do
        travel_to(Date.new(2025, 9, 1))
      end

      context 'with school admin' do
        let(:user) { create(:school_admin, school: create(:school, school_group: school_group)) }

        it { expect(html).not_to have_content(I18n.t('components.dashboards.group_reminders.review_tariffs.note')) }
      end

      context 'with the group admin' do
        let(:user) { create(:group_admin, school_group: school_group) }

        it { expect(html).to have_content(I18n.t('components.dashboards.group_reminders.review_tariffs.note')) }
      end
    end

    context 'when not in reminder period' do
      before do
        travel_to(Date.new(2025, 8, 1))
      end

      context 'with the group admin' do
        let(:user) { create(:group_admin, school_group: school_group) }

        it { expect(html).to have_content(I18n.t('components.dashboards.group_reminders.review_tariffs.note')) }
      end
    end
  end

  describe '#prompt_for_engagement?' do
    context 'with the group admin' do
      let(:user) { create(:group_admin, school_group: school_group) }

      it { expect(html).not_to have_content(I18n.t('components.dashboards.group_reminders.engagement.note')) }
    end

    context 'when there are active, unengaged schools' do
      let(:school_group) { create(:school_group, :with_active_schools) }

      context 'with the group admin' do
        let(:user) { create(:group_admin, school_group: school_group) }

        it { expect(html).to have_content(I18n.t('components.dashboards.group_reminders.engagement.note')) }
      end
    end

    context 'when there are active engaged schools' do
      let(:school_group) { create(:school_group, :with_active_schools, count: 3) }

      before do
        create(:observation, :activity, school: school_group.schools.first)
      end

      context 'with the group admin' do
        let(:user) { create(:group_admin, school_group: school_group) }

        it { expect(html).to have_content(I18n.t('components.dashboards.group_reminders.engagement.note')) }
      end
    end
  end

  describe '#prompt_for_onboarding?' do
    context 'with the group admin' do
      let(:user) { create(:group_admin, school_group: school_group) }

      it { expect(html).not_to have_content(I18n.t('components.dashboards.group_reminders.onboarding.note')) }
    end

    context 'with incomplete onboarding' do
      before do
        create(:school_onboarding, school_group: school_group)
      end

      context 'with the group admin' do
        let(:user) { create(:group_admin, school_group: school_group) }

        it { expect(html).to have_content(I18n.t('components.dashboards.group_reminders.onboarding.note')) }
      end
    end
  end
end
