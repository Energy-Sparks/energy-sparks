# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dashboards::GroupLearnMoreComponent, :include_application_helper, :include_url_helpers, type: :component do
  let(:school_group) { create(:school_group) }
  let(:params) do
    {
      id: 'custom-id',
      classes: 'extra-classes',
      school_group: school_group,
      user: nil
    }
  end
  let(:i18n_scope) { 'components.dashboards.group_learn_more' }
  let(:html) { render_inline(described_class.new(**params)) }

  it_behaves_like 'an application component' do
    let(:expected_classes) { params[:classes] }
    let(:expected_id) { params[:id] }
  end

  shared_examples 'a group with data available' do
    it { expect(html).not_to have_css('.data-disabled')}
    it { expect(html).not_to have_content(I18n.t('schools.show.coming_soon')) }
    it { expect(html).not_to have_content(I18n.t('intro_no_data', scope: i18n_scope)) }

    context 'with schools box' do
      let(:schools) { school_group.schools.by_name }

      it { expect(html).to have_content(I18n.t('schools.title', scope: i18n_scope)) }
      it { expect(html).to have_content(I18n.t('schools.intro', scope: i18n_scope)) }
      it { expect(html).to have_selector("form[action='#{schools_path}'][method='get']") }
      it { expect(html).to have_select(:school, options: ['Select a school...'] + schools.by_name.pluck(:name)) }
    end

    context 'with advice box' do
      it { expect(html).to have_content(I18n.t('advice.title', scope: i18n_scope)) }
      it { expect(html).to have_content(I18n.t('advice.intro', scope: i18n_scope)) }
      it { expect(html).to have_link(I18n.t('common.explore_energy_data'), href: school_group_advice_path(school_group)) }
    end
  end

  shared_examples 'a group without data available' do
    it { expect(html).to have_css('.data-disabled')}
    it { expect(html).to have_content(I18n.t('schools.show.coming_soon')) }
    it { expect(html).to have_content(I18n.t('intro_no_data', scope: i18n_scope)) }
  end

  context 'with no user' do
    context 'with no schools in group' do
      it_behaves_like 'a group without data available'
    end

    context 'with process data but not data enabled schools in group' do
      let!(:school) { create(:school, process_data: true, data_enabled: false, school_group:) }

      it_behaves_like 'a group without data available'
    end

    context 'with data enabled schools in group' do
      let!(:school) { create(:school, data_enabled: true, school_group:) }

      it_behaves_like 'a group with data available'
    end
  end

  context 'with admin user' do
    before do
      params.update(user: create(:admin))
    end

    context 'with no schools in group' do
      it_behaves_like 'a group without data available'
    end

    context 'with process data but not data enabled schools in group' do
      let!(:school) { create(:school, process_data: true, data_enabled: false, school_group:) }

      it_behaves_like 'a group with data available'
    end

    context 'with data enabled schools in group' do
      let!(:school) { create(:school, data_enabled: true, school_group:) }

      it_behaves_like 'a group with data available'
    end
  end
end
