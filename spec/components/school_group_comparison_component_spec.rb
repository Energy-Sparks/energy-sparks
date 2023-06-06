# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolGroupComparisonComponent, type: :component do
  let(:comparison) {
    OpenStruct.new(exemplar_school: 1, benchmark_school: 3, other_school: 4)
  }

  let(:params)  { { id: 'spec-id', comparison: comparison } }
  let(:component)  { SchoolGroupComparisonComponent.new(**params) }
  let(:html) { render_inline(component) }

  it 'renders ok' do
    expect(component.render?).to eq true
  end

  it "includes the values and the correct pluralisation of school" do
    expect(html).to have_content('1')
    expect(html).to have_content('3')
    expect(html).to have_content('4')
    expect(html).to have_content('School', count: 3)
    expect(html).to have_content('Schools', count: 2)
  end

  it "includes the category titles" do
    expect(html).to have_content(I18n.t('advice_pages.benchmarks.exemplar_school'))
    expect(html).to have_content(I18n.t('advice_pages.benchmarks.benchmark_school'))
    expect(html).to have_content(I18n.t('advice_pages.benchmarks.other_school'))
  end
end
