# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SchoolGroups::ComparisonReportListComponent, :include_url_helpers, type: :component do
  let(:params) do
    {
      school_group: school_group,
      fuel_types: fuel_types
    }
  end

  let(:fuel_types) { [:electricity] }
  let!(:school_group) { create(:school_group) }

  context 'with a simple list' do
    let(:fuel_type) { nil }

    subject(:html) do
      render_inline(described_class.new(**params)) do |c|
        c.with_link 'Link', fuel_type: fuel_type, report: :annual_energy_use
      end
    end

    it 'links to report' do
      expect(html).to have_link('Link',
                                href: compare_path(benchmark: :annual_energy_use, school_group_ids: [school_group.id]))
    end

    context 'with available fuel type' do
      let(:fuel_type) { :electricity }

      it 'links to report' do
        expect(html).to have_link('Link',
                                  href: compare_path(benchmark: :annual_energy_use, school_group_ids: [school_group.id]))
      end
    end

    context 'with other fuel type' do
      let(:fuel_type) { :gas }

      it 'does not link to report' do
        expect(html).not_to have_link('Link',
                                  href: compare_path(benchmark: :annual_energy_use, school_group_ids: [school_group.id]))
      end
    end
  end

  context 'with a named list' do
    let(:fuel_type) { nil }

    subject(:html) do
      render_inline(described_class.new(**params)) do |c|
        c.with_named 'Baseload variation', fuel_type: fuel_type, reports: {
          season_baseload_variation: 'Seasonal variation'
        }
      end
    end

    it 'renders sublist heading' do
      expect(html).to have_content('Baseload variation')
    end

    it 'links to report' do
      expect(html).to have_link('Seasonal variation',
                                href: compare_path(benchmark: :season_baseload_variation, school_group_ids: [school_group.id]))
    end

    context 'with available fuel type' do
      let(:fuel_type) { :electricity }

      it 'links to report' do
        expect(html).to have_link('Seasonal variation',
                                  href: compare_path(benchmark: :season_baseload_variation, school_group_ids: [school_group.id]))
      end
    end

    context 'with other fuel type' do
      let(:fuel_type) { :gas }

      it 'does not render sublist heading' do
        expect(html).not_to have_content('Baseload variation')
      end

      it 'does not link to report' do
        expect(html).not_to have_link('Seasonal variation',
                                  href: compare_path(benchmark: :season_baseload_variation, school_group_ids: [school_group.id]))
      end
    end
  end

  context 'with a fuel type list' do
    subject(:html) do
      render_inline(described_class.new(**params)) do |c|
        c.with_fuel_types 'Annual change in use', reports: {
          electricity: :change_in_electricity_since_last_year,
          gas: :change_in_gas_since_last_year
        }
      end
    end

    it 'renders sublist heading' do
      expect(html).to have_content('Annual change in use')
    end

    it 'links to electricity report' do
      expect(html).to have_link(I18n.t('common.electricity'),
                                href: compare_path(benchmark: :change_in_electricity_since_last_year,
                                                   school_group_ids: [school_group.id]))
    end

    it 'does not link to gas report' do
      expect(html).not_to have_link(I18n.t('common.gas'),
                                  href: compare_path(benchmark: :change_in_gas_since_last_year,
                                                     school_group_ids: [school_group.id]))
    end

    context 'with no fuel types' do
      let(:fuel_types) { [] }

      it 'does not render' do
        expect(html).not_to have_content('Annual change in use')
      end
    end

    context 'with additional fuel types' do
      let(:fuel_types) { [:electricity, :gas] }

      it 'links to electricity report' do
        expect(html).to have_link(I18n.t('common.electricity'),
                                  href: compare_path(benchmark: :change_in_electricity_since_last_year, school_group_ids: [school_group.id]))
      end

      it 'links to gas report' do
        expect(html).to have_link(I18n.t('common.gas'),
                                  href: compare_path(benchmark: :change_in_gas_since_last_year, school_group_ids: [school_group.id]))
      end
    end
  end
end
