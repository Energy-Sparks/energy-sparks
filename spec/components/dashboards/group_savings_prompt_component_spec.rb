# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dashboards::GroupSavingsPromptComponent, :include_url_helpers, type: :component do
  subject(:html) do
    render_inline(described_class.new(**params))
  end

  let(:school_group) { create(:school_group, :with_active_schools, count: 2) }
  let(:metric) { :kwh }

  let(:params) do
    {
      school_group: school_group,
      schools: school_group.schools,
      metric: metric,
      id: 'custom-id',
      classes: 'extra-classes'
    }
  end

  include_context 'with a group management priority' do
    let(:schools) { school_group.schools }
  end

  context 'with priority actions' do
    it_behaves_like 'an application component' do
      let(:expected_classes) { 'extra-classes' }
      let(:expected_id) { 'custom-id' }
    end

    it { expect(html).to have_content('Spending too much money on heating') }
    it { expect(html).to have_content('gas') }
    it { expect(html).to have_content('2 schools') }
    it { expect(html).to have_content('4,400 kWh') }

    it {
      expect(html).to have_link(I18n.t('components.dashboards.group_savings_prompt.view_all_savings'),
                                   href: priorities_school_group_advice_path(school_group))
    }

    context 'when displaying co2' do
      let(:metric) { :co2 }

      it { expect(html).to have_content('2,200 kg CO2') }
    end

    context 'when displaying gbp' do
      let(:metric) { :gbp }

      it { expect(html).to have_content('£2,000') }
    end
  end
end
