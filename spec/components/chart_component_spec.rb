# frozen_string_literal: true

require "rails_helper"

RSpec.describe ChartComponent, type: :component, include_url_helpers: true do
  let(:school) { create(:school) }
  let(:html) { render_inline(ChartComponent.new(**params)) }
  let(:chart_type) { :baseload }
  let(:all_params) { { school: school, chart_type: chart_type, title: 'Title text', subtitle: 'Subtitle text', html_class: 'usage-chart' } }

  context "with all params" do
    let(:params) { all_params }
    it { expect(html).to have_selector("h4", text: "Title text") }
    it { expect(html).to have_selector("h5", text: "Subtitle text") }
    it { expect(html).to have_selector("div", id: "chart_wrapper_baseload") }
    it { expect(html).to have_selector("div", class: "usage-chart") }
  end
end
