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

  def expected_compare_path(school_group, benchmark)
    compare_path(group: true, benchmark: benchmark, school_group_ids: [school_group.id])
  end

  context 'with a simple list' do
    let(:fuel_type) { nil }
    let!(:report) { create(:report, key: :annual_energy_use, public: true) }

    subject(:html) do
      render_inline(described_class.new(**params)) do |c|
        c.with_link 'Link', fuel_type: fuel_type, report: report.key
      end
    end

    it 'links to report' do
      expect(html).to have_link('Link', href: expected_compare_path(school_group, report.key))
    end

    context 'with available fuel type' do
      let(:fuel_type) { :electricity }

      it 'links to report' do
        expect(html).to have_link('Link', href: expected_compare_path(school_group, report.key))
      end
    end

    context 'with other fuel type' do
      let(:fuel_type) { :gas }

      it 'does not link to report' do
        expect(html).not_to have_link('Link', href: expected_compare_path(school_group, report.key))
      end
    end

    context 'with private report' do
      let!(:report) { create(:report, key: :annual_energy_use, public: false) }

      it 'does not link to report' do
        expect(html).not_to have_link('Link', href: expected_compare_path(school_group, report.key))
      end
    end
  end

  context 'with a named list' do
    let(:fuel_type) { nil }
    let!(:report) { create(:report, key: :seasonal_baseload_variation, public: true) }

    subject(:html) do
      render_inline(described_class.new(**params)) do |c|
        c.with_named 'Baseload variation', fuel_type: fuel_type, reports: {
          :seasonal_baseload_variation => 'Seasonal'
        }
      end
    end

    it 'renders sublist heading' do
      expect(html).to have_content('Baseload variation')
    end

    it 'links to report' do
      expect(html).to have_link('Seasonal', href: expected_compare_path(school_group, :seasonal_baseload_variation))
    end

    context 'with available fuel type' do
      let(:fuel_type) { :electricity }

      it 'links to report' do
        expect(html).to have_link('Seasonal', href: expected_compare_path(school_group, :seasonal_baseload_variation))
      end
    end

    context 'with other fuel type' do
      let(:fuel_type) { :gas }

      it 'does not render sublist heading' do
        expect(html).not_to have_content('Baseload variation')
      end

      it 'does not link to report' do
        expect(html).not_to have_link('Seasonal', href: expected_compare_path(school_group, :seasonal_baseload_variation))
      end
    end

    context 'with private report' do
      let!(:report) { create(:report, key: :seasonal_baseload_variation, public: false) }

      it 'does not render sublist heading' do
        expect(html).not_to have_content('Baseload variation')
      end

      it 'does not link to report' do
        expect(html).not_to have_link('Seasonal', href: expected_compare_path(school_group, :seasonal_baseload_variation))
      end
    end
  end

  context 'with a fuel type list' do
    let(:public) { true }

    before do
      create(:report, key: :change_in_electricity_since_last_year, public:)
      create(:report, key: :change_in_gas_since_last_year, public:)
    end

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
                                href: expected_compare_path(school_group, :change_in_electricity_since_last_year))
    end

    it 'does not link to gas report' do
      expect(html).not_to have_link(I18n.t('common.gas'),
                                  href: expected_compare_path(school_group, :change_in_gas_since_last_year))
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
                                  href: expected_compare_path(school_group, :change_in_electricity_since_last_year))
      end

      it 'links to gas report' do
        expect(html).to have_link(I18n.t('common.gas'),
                                  href: expected_compare_path(school_group, :change_in_gas_since_last_year))
      end
    end

    context 'with private reports' do
      let(:public) { false }

      it 'does not render' do
        expect(html).not_to have_content('Annual change in use')
      end
    end

    context 'with one private report' do
      let(:fuel_types) { [:electricity, :gas] }

      before do
        Comparison::Report.find_by_key(:change_in_gas_since_last_year).update!(public: false)
      end

      it 'renders sublist heading' do
        expect(html).to have_content('Annual change in use')
      end

      it 'does not link to the private report' do
        expect(html).not_to have_link(I18n.t('common.gas'),
                                  href: expected_compare_path(school_group, :change_in_gas_since_last_year))
      end
    end

    context 'with label override' do
      subject(:html) do
        render_inline(described_class.new(**params)) do |c|
          c.with_fuel_types 'Annual change in use', reports: {
            electricity: { report: :change_in_electricity_since_last_year, label: 'Leccy' },
            gas: { report: :change_in_gas_since_last_year, label: 'The gas' }
          }
        end
      end

      it 'renders sublist heading' do
        expect(html).to have_content('Annual change in use')
      end

      it 'links to electricity report' do
        expect(html).to have_link('Leccy',
                                  href: expected_compare_path(school_group, :change_in_electricity_since_last_year))
      end

      it 'does not link to gas report' do
        expect(html).not_to have_link('The gas',
                                    href: expected_compare_path(school_group, :change_in_gas_since_last_year))
      end

      context 'with additional fuel types' do
        let(:fuel_types) { [:electricity, :gas] }

        it 'links to electricity report' do
          expect(html).to have_link('Leccy',
                                    href: expected_compare_path(school_group, :change_in_electricity_since_last_year))
        end

        it 'links to gas report' do
          expect(html).to have_link('The gas',
                                    href: expected_compare_path(school_group, :change_in_gas_since_last_year))
        end
      end

      context 'with private reports' do
        let(:public) { false }

        it 'does not render' do
          expect(html).not_to have_content('Annual change in use')
        end
      end
    end
  end
end
