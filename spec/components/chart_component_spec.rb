# frozen_string_literal: true

require "rails_helper"

RSpec.describe ChartComponent, type: :component, include_url_helpers: true do
  let(:school) { create(:school) }
  let(:chart_type) { :baseload }
  let(:params) { { school: school, chart_type: chart_type, html_class: 'usage-chart' } }

  context "with all params" do
    let(:html) { render_inline(ChartComponent.new(**params)) }

    it { expect(html).to have_selector("div", id: "chart_wrapper_baseload") }
    it { expect(html).to have_selector("div", class: "usage-chart") }

    it 'sets up chart config data attribute' do
      expect(html).to have_selector("div", id: 'chart_baseload') { |d| JSON.parse(d['data-chart-config'])['type'] == 'baseload' }
    end
  end

  context "with title, subtitle, header and footer slots" do
    let(:html) do
      render_inline ChartComponent.new(**params) do |c|
        c.with_title    { "I'm a title" }
        c.with_subtitle { "I'm a subtitle" }
        c.with_header   { "I'm a header" }
        c.with_footer   { "I'm a footer" }
      end
    end
    it { expect(html).to have_selector("h4", text: "I'm a title") }
    it { expect(html).to have_selector("h4", id: "chart_baseload_title") }
    it { expect(html).to have_selector("h5", text: "I'm a subtitle") }
    it { expect(html).to have_selector("p", text: "I'm a header") }
    it { expect(html).to have_selector("p", text: "I'm a footer") }
  end
end
