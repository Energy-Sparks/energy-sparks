# frozen_string_literal: true

# rubocop:disable RSpec/MultipleMemoizedHelpers
require 'rails_helper'

RSpec.describe SchoolGroups::SchoolsStatusComponent, :include_url_helpers, type: :component do
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:school_group) { create(:school_group) }
  let!(:school) { create(:school, school_group:, visible: true, data_enabled: true) }
  # let!(:onboarding)   { create(:school_onboarding, school_group:) }

  let(:params) do
    {
      id:, classes:,
      school_group:,
      schools: School.all,
      onboardings: SchoolOnboarding.all
    }
  end

  subject(:html) { render_inline(described_class.new(**params)) }

  it_behaves_like 'an application component' do
    let(:expected_classes) { classes }
    let(:expected_id) { id }
  end

  let(:fuel_configuration) do
    { has_electricity: false,
      has_gas: false,
      has_storage_heaters: false,
      has_solar_pv: false }
  end

  it 'shows the school name' do
    expect(html).to have_css('table tbody tr td', text: school.name)
  end

  context 'when school is not visible' do
    let!(:school) { create(:school, visible: false, school_group:) }

    it 'does shows fuel type icon headers' do
      expect(html).to have_css('th i.fa-sun')
      expect(html).to have_css('th i.fa-bolt')
      expect(html).to have_css('th i.fa-fire')
      expect(html).to have_css('th i.fa-fire-alt')
    end

    it 'shows the school name' do
      expect(html).to have_content(school.name)
    end

    it 'shows the timer icon for each fuel type' do
      expect(html).to have_css('td i.fa-hourglass-half', count: 4)
    end
  end

  Schools::FuelConfiguration.fuel_types.each do |fuel_type|
    context "when school has #{fuel_type}" do
      let!(:school) { create(:school, :with_fuel_configuration, **fuel_configuration.merge(fuel), school_group:) }

      let(:fuel) { { "has_#{fuel_type}": true } }

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

  # ### todo test with onboardings
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
