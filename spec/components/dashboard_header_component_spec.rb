# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DashboardHeaderComponent, type: :component do
  let(:school) { create(:school) }

  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:params) do
    {
      id: id,
      classes: classes,
      school: school
    }
  end

  let(:html) { render_inline(described_class.new(**params)) }

  it_behaves_like 'an application component' do
    let(:expected_classes) { classes }
    let(:expected_id) { id }
  end

  it { expect(html).to have_content(I18n.t('components.dashboard_header.title')) }
  it { expect(html).to have_content('Explore the latest energy data') }
  it { expect(html).to have_content(school.name) }
  it { expect(html).to have_content(school.address) }
  it { expect(html).to have_content(school.postcode) }
  it { expect(html).to have_content(I18n.t("common.school_types.#{school.school_type}")) }

  context 'with alternative text' do
    let(:params) do
      {
        title: I18n.t('advice_pages.baseload.analysis.title'),
        intro: I18n.t('advice_pages.baseload.analysis.summary'),
        school: school
      }
    end

    it { expect(html).to have_content(I18n.t('advice_pages.baseload.analysis.title')) }
    it { expect(html).to have_content(I18n.t('advice_pages.baseload.analysis.summary')) }
  end

  context 'without school' do
    let(:params) do
      {
        show_school: false,
        school: school
      }
    end

    it { expect(html).to have_no_content(school.name) }
    it { expect(html).to have_no_content(school.address) }
    it { expect(html).to have_no_content(school.postcode) }
    it { expect(html).to have_no_content(I18n.t("common.school_types.#{school.school_type}")) }
  end
end
