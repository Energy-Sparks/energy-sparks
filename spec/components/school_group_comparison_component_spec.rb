# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolGroupComparisonComponent, type: :component do
  let(:school_group) { create(:school_group) }
  let(:comparison) {
    {
      benchmark_school: [{"school_id"=>1, "school_slug"=>"school-1", "school_name"=>"School 1"}],
      exemplar_school: [
        {"school_id"=>2, "school_slug"=>"school-2", "school_name"=>"School 2"},
        {"school_id"=>3, "school_slug"=>"school-3", "school_name"=>"School 3"},
        {"school_id"=>4, "school_slug"=>"school-4", "school_name"=>"School 4"}
      ],
      other_school: [
        {"school_id"=>5, "school_slug"=>"school-5", "school_name"=>"School 5"},
        {"school_id"=>6, "school_slug"=>"school-6", "school_name"=>"School 6"},
        {"school_id"=>7, "school_slug"=>"school-7", "school_name"=>"School 7"},
        {"school_id"=>8, "school_slug"=>"school-8", "school_name"=>"School 8"}
      ]
    }
  }

  let(:params) { { id: 'spec-id', comparison: comparison, advice_page_key: :baseload } }
  let(:component)  { SchoolGroupComparisonComponent.new(**params) }
  let(:html) { render_inline(component) }

  it 'renders ok' do
    expect(component.render?).to eq true
  end

  it "includes the values and the correct pluralisation of school" do
    expect(html).to have_content('1')
    expect(html).to have_content('3')
    expect(html).to have_content('4')
  end

  it "includes the category titles" do
    expect(html).to have_content(I18n.t('advice_pages.benchmarks.exemplar_school'))
    expect(html).to have_content(I18n.t('advice_pages.benchmarks.benchmark_school'))
    expect(html).to have_content(I18n.t('advice_pages.benchmarks.other_school'))
  end
end
