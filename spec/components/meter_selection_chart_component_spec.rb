# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MeterSelectionChartComponent, type: :component, include_url_helpers: true do
  let(:school) { create(:school) }

  let(:aggregate_school_service) do
    instance_double(AggregateSchoolService, aggregate_school: meter_collection)
  end

  let(:meter_collection) do
    build(:meter_collection, :with_aggregate_meter, fuel_type: :electricity)
  end

  let(:meters) do
    build_list(:meter, 3, type: :electricity)
  end

  before do
    meters.each do |meter|
      meter_collection.add_electricity_meter(meter)
    end
  end

  let(:meter_selection) { Charts::MeterSelection.new(school, aggregate_school_service, :electricity, include_whole_school: false) }

  let(:params) do
    {
      chart_type: :baseload,
      meter_selection: meter_selection,
      chart_subtitle_key: 'advice_pages.baseload.analysis.charts.long_term_baseload_meter_chart_subtitle'
    }
  end

  context 'when rendering' do
    let(:html) { render_inline(described_class.new(**params)) }

    it 'creates expected chart, defaulting to first meter' do
      expect(html).to have_selector('div', id: "chart_baseload_#{meters.first.mpan_mprn}") { |d| JSON.parse(d['data-chart-config'])['type'] == 'baseload' }
    end

    it 'adds sets up the meter selection form' do
      expect(html).to have_selector('form#chart-filter')
      within('form#chart-filter') do
        expect(html).to have_selector(:configuration, visible: :hidden)
        expect(html).to have_selector(:descriptions, visible: :hidden)
        expect(html).to have_selector(:meter, visible: :visible)
      end
    end

    context 'when there is only a single meter' do
      let(:meters) { [build(:meter, type: :electricity)] }

      it 'still adds the expected chart, defaulting to first meter' do
        expect(html).to have_selector('div', id: "chart_baseload_#{meters.first.mpan_mprn}") { |d| JSON.parse(d['data-chart-config'])['type'] == 'baseload' }
      end

      it 'does not add the form' do
        expect(html).not_to have_selector('form#chart-filter')
      end
    end

    context 'with title, header and footer slots' do
      let(:html) do
        render_inline described_class.new(**params) do |c|
          c.with_title { I18n.t('advice_pages.baseload.analysis.charts.long_term_baseload_meter_chart_title') }
          c.with_header   { "<strong>I'm a header</strong>".html_safe }
          c.with_footer   { "<small>I'm a footer</small>".html_safe }
        end
      end

      it 'adds title' do
        expect(html).to have_content(I18n.t('advice_pages.baseload.analysis.charts.long_term_baseload_meter_chart_title'))
      end

      it { expect(html).to have_selector('strong', text: "I'm a header") }
      it { expect(html).to have_selector('small', text: "I'm a footer") }

      context 'when theres a single meter' do
        let(:meters) { [build(:meter, type: :electricity)] }

        it 'adds the title' do
          expect(html).to have_content(I18n.t('advice_pages.baseload.analysis.charts.long_term_baseload_meter_chart_title'))
        end

        it { expect(html).to have_selector('strong', text: "I'm a header") }
        it { expect(html).to have_selector('small', text: "I'm a footer") }
      end
    end
  end

  describe '#chart_descriptions' do
    subject(:component) { described_class.new(**params) }

    it 'returns translated strings with default for unknown meter' do
      result = component.chart_descriptions
      expect(result.size).to eq(3)
      first_meter = meters.first
      expect(result[first_meter.mpan_mprn]).to eq("Electricity baseload from #{first_meter.amr_data.start_date.to_fs(:es_short)} to #{first_meter.amr_data.end_date.to_fs(:es_short)} for #{first_meter.name_or_mpan_mprn}")
    end
  end

  describe '#meter_selection_options' do
    subject(:component) { described_class.new(**params) }

    it { expect(component.meter_selection_options).to match_array(meter_selection.meter_selection_options) }
  end

  describe '#render?' do
    subject(:component) { described_class.new(**params) }

    context 'when there are no meters' do
      let(:meters) { [] }

      it 'does not render' do
        expect(component.render?).to eq(false)
      end
    end
  end
end
