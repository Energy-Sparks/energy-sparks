# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdviceRemindersComponent, :include_application_helper, :include_url_helpers, type: :component do
  subject(:component) do
    described_class.new(**params)
  end

  let(:id) { 'custom-id'}
  let(:classes) { 'extra-classes' }
  let(:user) { create(:admin) }
  let(:school) { create(:school) }

  let(:params) do
    {
      school: school,
      user: user,
      id: id,
      classes: classes
    }
  end

  context 'when rendering' do
    let(:html) do
      render_inline(component)
    end

    it_behaves_like 'an application component' do
      let(:expected_classes) { classes }
      let(:expected_id) { id }
    end

    it { expect(html).to have_content(I18n.t('advice_pages.insights.recommendations.actions_title')) }

    it {
      expect(html).to have_link(I18n.t('common.labels.choose_activity'),
                                   href: school_recommendations_path(school, scope: :adult))
    }

    it { expect(html).to have_content(I18n.t('schools.show.set_targets')) }

    it {
      expect(html).to have_link(I18n.t('schools.show.set_target'),
                                   href: school_school_targets_path(school))
    }

    context 'with target needing review' do
      before do
        create(:school_target, school: school)
        service = instance_double(Targets::SchoolTargetService)
        allow(service).to receive(:prompt_to_review_target?).and_return(true)
        allow(Targets::SchoolTargetService).to receive(:new).and_return(service)
      end

      it { expect(html).to have_content(I18n.t('schools.show.revisit_targets')) }

      it {
        expect(html).to have_link(I18n.t('schools.show.review_target'),
                                     href: school_school_targets_path(school))
      }
    end

    context 'with expired target' do
      before do
        create(:school_target, school: school, start_date: Date.yesterday.prev_year, target_date: Date.yesterday)
      end

      it { expect(html).to have_content('Your school set a target to reduce its energy usage') }

      it {
        expect(html).to have_link(I18n.t('schools.show.review_progress'),
                                     href: school_school_targets_path(school))
      }
    end

    it { expect(html).to have_no_content(I18n.t('schools.school_targets.achieving_your_targets.view_recent_alerts')) }
    it { expect(html).to have_no_link(I18n.t('common.labels.view_alerts'), href: alerts_school_advice_path(school)) }

    it { expect(html).to have_no_content(I18n.t('schools.school_targets.achieving_your_targets.view_energy_saving_opportunities')) }
    it { expect(html).to have_no_link(I18n.t('common.labels.view_opportunities'), href: priorities_school_advice_path(school)) }

    context 'with alerts and priorities' do
      include_context 'with dashboard alerts'

      it { expect(html).to have_content(I18n.t('schools.school_targets.achieving_your_targets.view_recent_alerts')) }
      it { expect(html).to have_link(I18n.t('common.labels.view_alerts'), href: alerts_school_advice_path(school)) }

      it { expect(html).to have_content(I18n.t('schools.school_targets.achieving_your_targets.view_energy_saving_opportunities')) }
      it { expect(html).to have_link(I18n.t('common.labels.view_opportunities'), href: priorities_school_advice_path(school)) }
    end
  end
end
