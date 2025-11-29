# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SchoolGroups::SchoolsStatusComponent, :include_url_helpers, type: :component do
  let(:school_group) { create(:school_group) }
  let!(:school) { create(:school, school_group:, visible: true, data_enabled: true) }

  let(:params) do
    {
      id: 'custom-id', classes: 'extra-classes',
      school_group:,
      schools: School.all,
      onboardings: SchoolOnboarding.all
    }
  end

  subject(:html) { render_inline(described_class.new(**params)) }

  it_behaves_like 'an application component' do
    let(:expected_classes) { params[:classes] }
    let(:expected_id) { params[:id] }
  end

  let(:fuel_configuration) do
    { has_electricity: false,
      has_gas: false,
      has_storage_heaters: false,
      has_solar_pv: false }
  end

  it 'shows the school name' do
    expect(html).to have_content(school.name)
  end

  shared_examples 'fuel type icon headers' do
    it 'shows the fuel type icon headers' do
      expect(html).to have_css('th i.fa-sun')
      expect(html).to have_css('th i.fa-bolt')
      expect(html).to have_css('th i.fa-fire')
      expect(html).to have_css('th i.fa-fire-alt')
    end
  end

  shared_examples 'hourglass icons for all fuel types' do
    it 'shows the hourglass icon for each fuel type' do
      expect(html).to have_css('td i.fa-hourglass-half', count: 4)
    end
  end

  shared_examples 'linking to school specific page' do
    it 'links to the school specific page' do
      expect(html).to have_link(school.name, href: school_school_group_status_index_path(school_group, school))
    end
  end

  context 'when school is onboarding (with no school record)' do
    let!(:onboarding) { create(:school_onboarding, school_group:) }

    it 'shows the school name' do
      expect(html).to have_content(onboarding.name)
    end

    it 'does not link to a school specific page' do
      expect(html).not_to have_link(onboarding.name)
    end

    it 'shows the school status as onboarding' do
      expect(html).to have_css('td', text: I18n.t('schools.status.onboarding'))
    end

    it_behaves_like 'fuel type icon headers'
    it_behaves_like 'hourglass icons for all fuel types'
  end

  context 'when there is an onboarding (with school record)' do
    let(:school) { create(:school, data_enabled: false, visible: false, school_group:) }
    let(:onboarding) { create(:school_onboarding, school: school, school_group:) }

    it 'shows the school status as onboarding' do
      expect(html).to have_css('td', text: I18n.t('schools.status.onboarding'))
    end

    it_behaves_like 'linking to school specific page'
  end

  context 'when school is not visible or data enabled' do
    let!(:school) { create(:school, data_enabled: false, visible: false, school_group:) }

    it 'shows the school status as onboarding' do
      expect(html).to have_css('td', text: I18n.t('schools.status.onboarding'))
    end

    it_behaves_like 'linking to school specific page'
    it_behaves_like 'fuel type icon headers'
    it_behaves_like 'hourglass icons for all fuel types'
  end

  context 'when school is visible but not data enabled' do
    let!(:school) { create(:school, visible: true, data_enabled: false, school_group:) }

    it 'shows the school status as visible' do
      expect(html).to have_css('td', text: I18n.t('schools.status.visible'))
    end

    it_behaves_like 'linking to school specific page'
    it_behaves_like 'fuel type icon headers'
    it_behaves_like 'hourglass icons for all fuel types'
  end

  Schools::FuelConfiguration.fuel_types.each do |fuel_type|
    context "when school has #{fuel_type}" do
      let!(:school) { create(:school, :with_fuel_configuration, **fuel_configuration.merge(fuel), school_group:) }

      let(:fuel) { { "has_#{fuel_type}": true } }

      it_behaves_like 'linking to school specific page'

      it "shows a tick icon for #{fuel_type} fuel type" do
        expect(html).to have_css("td span[title=\"#{I18n.t(fuel_type, scope: 'common')}\"] i.fa-circle-check")
      end

      it 'shows a cross icon for other fuel types' do
        (Schools::FuelConfiguration.fuel_types - [fuel_type]).each do |other_fuel_type|
          expect(html).to have_css("td span[title=\"#{I18n.t(other_fuel_type, scope: 'common')}\"] i.fa-xmark")
        end
      end
    end
  end
end
