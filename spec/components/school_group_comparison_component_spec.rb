# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolGroupComparisonComponent, type: :component do
  let(:school_group) { create(:school_group) }
  let(:params)  { { id: 'spec-id', school_group: school_group } }
  let(:component)  { SchoolGroupComparisonComponent.new(**params) }
  let(:html) { render_inline(component) }

  before do
    8.times { create(:school, school_group: school_group) }
    allow_any_instance_of(SchoolGroup).to receive(:categorise_schools) do
      OpenStruct.new(
        exemplar_school: [school_group.schools[0]],
        benchmark_school: school_group.schools[1..3],
        other_school: school_group.schools[4..7]
      )
    end
  end

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
