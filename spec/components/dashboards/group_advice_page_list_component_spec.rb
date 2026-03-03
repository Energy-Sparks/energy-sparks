# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dashboards::GroupAdvicePageListComponent, :include_application_helper, :include_url_helpers, type: :component do
  let!(:school_group) { create(:school_group) }
  let(:fuel_types) { [:electricity, :gas, :storage_heaters] }
  let!(:school) { create(:school, school_group:) }

  context 'when advice pages exist' do
    before do
      create(:advice_page, key: :baseload, fuel_type: :electricity)
      create(:advice_page, key: :gas_long_term, fuel_type: :gas)
      render_inline(described_class.new(school_group:, schools: school_group.schools, fuel_types:))
    end

    it { expect(page).to have_css('div.dashboards-group-advice-page-list-component') }

    it 'includes section titles for the group fuel types with group advice pages' do
      [:electricity, :gas].each do |fuel_type|
        expect(page).to have_content(I18n.t(fuel_type, scope: 'advice_pages.nav.sections'))
      end
    end

    it 'does not include pages for other types' do
      expect(page).not_to have_content(I18n.t(:storage_heater, scope: 'advice_pages.nav.sections'))
    end

    it 'describes the pages' do
      expect(page).to have_content(I18n.t(:baseload, scope: 'school_groups.advice_pages.show.page_summary'))
    end

    it 'links to the pages' do
      expect(page).to have_link(I18n.t('schools.show.find_out_more'),
                                href: polymorphic_path([:insights, school_group, :advice, :baseload]))
    end

    context 'with limited group fuel types' do
      let(:fuel_types) { [:electricity] }

      it 'includes section titles for the group fuel types with group advice pages' do
        expect(page).to have_content(I18n.t(:electricity, scope: 'advice_pages.nav.sections'))
      end

      it 'does not include pages for other types' do
        [:gas, :storage_heater].each do |fuel_type|
          expect(page).not_to have_content(I18n.t(fuel_type, scope: 'advice_pages.nav.sections'))
        end
      end
    end
  end

  context 'when schools have a benchmark' do
    before do
      advice_page = create(:advice_page, key: :baseload, fuel_type: :electricity)
      create(:advice_page_school_benchmark, school: school, advice_page: advice_page, benchmarked_as: :benchmark_school)
      render_inline(described_class.new(school_group:, schools: school_group.schools, fuel_types:))
    end

    it { expect(page).to have_content(I18n.t('advice_pages.benchmarks.benchmark_school')) }
  end
end
