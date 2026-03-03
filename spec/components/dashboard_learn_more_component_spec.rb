# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DashboardLearnMoreComponent, :include_url_helpers, type: :component do
  let(:school) { create(:school) }
  let(:user) { create(:school_admin, school: school)}
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:params) do
    {
      id: id,
      classes: classes,
      school: school,
      user: user
    }
  end

  let(:html) { render_inline(described_class.new(**params)) }

  it_behaves_like 'an application component' do
    let(:expected_classes) { classes }
    let(:expected_id) { id }
  end

  shared_examples 'a data enabled panel' do
    it { expect(html).to have_css('.data-enabled')}
    it { expect(html).to have_content(I18n.t('components.dashboard_learn_more.adult.title'))}
    it { expect(html).to have_content(I18n.t('components.dashboard_learn_more.adult.intro'))}

    it 'links to the analysis' do
      expect(html).to have_link(I18n.t('common.explore_energy_data'),
                                href: school_advice_path(school))
      expect(html).to have_link(I18n.t('components.dashboard_learn_more.adult.opportunities'),
                                href: priorities_school_advice_path(school))
    end
  end

  context 'when school is data enabled' do
    it_behaves_like 'a data enabled panel'

    context 'with solar pv' do
      let(:school) { create(:school, :with_fuel_configuration, has_solar_pv: true) }

      it { expect(html).to have_content(I18n.t('components.dashboard_learn_more.adult.title_with_solar_pv'))}
    end
  end

  context 'when school is not data enabled' do
    let(:school) { create(:school, data_enabled: false) }

    it { expect(html).to have_css('.data-disabled')}
    it { expect(html).to have_content(I18n.t('schools.show.coming_soon'))}
    it { expect(html).to have_content(I18n.t('schools.show.configuring_data_access'))}

    it 'does not link to the analysis' do
      expect(html).not_to have_link(I18n.t('common.explore_energy_data'),
                                    href: school_advice_path(school))
      expect(html).not_to have_link(I18n.t('components.dashboard_learn_more.adult.opportunities'),
                                    href: priorities_school_advice_path(school))
    end

    context 'with admin' do
      let(:user) { create(:admin) }

      it_behaves_like 'a data enabled panel'
    end
  end
end
