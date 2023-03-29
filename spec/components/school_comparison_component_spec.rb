require "rails_helper"

RSpec.describe SchoolComparisonComponent, type: :component do

  let(:comparison) {
    Schools::Comparison.new(
      school_value: 15,
      benchmark_value: 20,
      exemplar_value: 10,
      unit: :kw
    )
  }

  let(:params)  { { id: 'spec-id', comparison: comparison } }

  context 'when the comparison only has exemplar and school values' do
    let(:comparison) {
      Schools::Comparison.new(
        school_value: 150,
        benchmark_value: nil,
        exemplar_value: 10,
        unit: :kw
      )
    }
    let(:component)  { SchoolComparisonComponent.new(**params) }
    let(:html) do
      render_inline(component)
    end
    it 'still renders' do
      expect(component.render?).to eq true
    end
    it 'uses adjusts values for footer' do
      expect(component.benchmark_value).to eq nil
      expect(component.other_value).to eq '10 kW'
    end
    it "classifies the school as other_school" do
      expect(component.category).to eq 'other_school'
      within '.school-comparison-component-callout-box .body' do
        expect(html).to have_content('>15 kW')
      end
    end
  end

  context 'with benchmark school' do
    let(:html) do
      render_inline(SchoolComparisonComponent.new(**params))
    end

    it "has the right id" do
      expect(html).to have_css('#spec-id')
    end

    it "includes the values" do
      expect(html).to have_content('10 kW')
      expect(html).to have_content('15 kW')
      expect(html).to have_content('20 kW')
    end

    it "classifies the school" do
      within '.school-comparison-component-callout-box .body' do
        expect(html).to have_content('15 kW')
      end
    end

    it "adds responsive classes to other categories" do
      expect(html).to have_css('div.exemplar_school.d-none')
      expect(html).to_not have_css('div.benchmark_school.d-none')
      expect(html).to have_css('div.other_school.d-none')
    end
  end

  context 'with other school' do
    let(:comparison) {
      Schools::Comparison.new(
        school_value: 150,
        benchmark_value: 20,
        exemplar_value: 10,
        unit: :kw
      )
    }
    let(:html) do
      render_inline(SchoolComparisonComponent.new(**params))
    end

    it "classifies the school" do
      within '.school-comparison-component-callout-box .body' do
        expect(html).to have_content('150 kW')
      end
    end

    it "adds responsive classes to other categories" do
      expect(html).to have_css('div.exemplar_school.d-none')
      expect(html).to have_css('div.benchmark_school.d-none')
      expect(html).to_not have_css('div.other_school.d-none')
    end
  end

  context 'with callout footer' do
    let(:html) do
      render_inline(SchoolComparisonComponent.new(**params)) do |c|
        c.with_callout_footer { "Custom footer" }
      end
    end
    it "adds the callout footer" do
      within '.school-comparison-component-callout-box .footer' do
        expect(html).to have_content("Custom footer")
      end
    end
  end
end
