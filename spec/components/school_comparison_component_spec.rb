require 'rails_helper'

RSpec.describe SchoolComparisonComponent, type: :component do
  let(:comparison) do
    Schools::Comparison.new(
      school_value: 15,
      benchmark_value: 20,
      exemplar_value: 10,
      unit: :kw
    )
  end

  let(:params)  { { id: 'spec-id', comparison: comparison } }

  context 'when the comparison only has exemplar and school values' do
    let(:comparison) do
      Schools::Comparison.new(
        school_value: 150,
        benchmark_value: nil,
        exemplar_value: 10,
        unit: :kw
      )
    end
    let(:component) { SchoolComparisonComponent.new(**params) }

    before { render_inline(component) }

    it 'still renders' do
      expect(component.render?).to eq true
    end

    it 'uses adjusts values for footer' do
      expect(component.benchmark_value).to eq nil
      expect(component.other_value).to eq '10 kW'
    end

    it 'classifies the school as other_school' do
      expect(component.category).to eq 'other_school'
      expect(page.find('.school-comparison-component .callout-box .body')).to have_text('150 kW')
    end
  end

  context 'the greater and less than arrows next to category values depend on the low is good value of the comparison object' do
    let(:comparison) do
      Schools::Comparison.new(
        school_value: 150,
        benchmark_value: nil,
        exemplar_value: 10,
        unit: :kw
      )
    end
    let(:component) { SchoolComparisonComponent.new(**params) }

    it 'shows greater and less than arrows for each category when the low is good value is false' do
      allow_any_instance_of(Schools::Comparison).to receive(:low_is_good).and_return(false)
      expect(component.exemplar_value_sign).to eq('&gt;')
      expect(component.benchmark_value_sign).to eq('&gt;')
      expect(component.other_value_sign).to eq('&lt;')
    end

    it 'shows greater and less than arrows for each category when the low is good value is true' do
      allow_any_instance_of(Schools::Comparison).to receive(:low_is_good).and_return(true)
      expect(component.exemplar_value_sign).to eq('&lt;')
      expect(component.benchmark_value_sign).to eq('&lt;')
      expect(component.other_value_sign).to eq('&gt;')
    end
  end

  context 'with benchmark school' do
    let!(:html) { render_inline(described_class.new(**params)) }

    it 'has the right id' do
      expect(html).to have_css('#spec-id')
    end

    it 'includes the values' do
      expect(html).to have_text('10 kW')
      expect(html).to have_text('15 kW')
      expect(html).to have_text('20 kW')
    end

    it 'classifies the school' do
      expect(page.find('.school-comparison-component .callout-box .body')).to have_text('15 kW')
    end

    it 'adds responsive classes to other categories' do
      expect(html).to have_css('div.exemplar_school.d-none')
      expect(html).to have_no_css('div.benchmark_school.d-none')
      expect(html).to have_css('div.other_school.d-none')
    end
  end

  context 'with other school' do
    let(:comparison) do
      Schools::Comparison.new(
        school_value: 150,
        benchmark_value: 20,
        exemplar_value: 10,
        unit: :kw
      )
    end
    let!(:html) { render_inline(described_class.new(**params)) }

    it 'classifies the school' do
      expect(page.find('.school-comparison-component .callout-box .body')).to have_text('150 kW')
    end

    it 'adds responsive classes to other categories' do
      expect(html).to have_css('div.exemplar_school.d-none')
      expect(html).to have_css('div.benchmark_school.d-none')
      expect(html).to have_no_css('div.other_school.d-none')
    end
  end

  context 'with callout footer' do
    before do
      render_inline(SchoolComparisonComponent.new(**params)) do |c|
        c.with_footer { 'Custom footer' }
      end
    end

    it 'adds the callout footer' do
      expect(page.find('.school-comparison-component .callout-box .footer')).to have_text('Custom footer')
    end
  end
end
