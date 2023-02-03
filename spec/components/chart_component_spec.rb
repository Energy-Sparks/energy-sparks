# frozen_string_literal: true

require "rails_helper"

RSpec.describe ChartComponent, type: :component, include_url_helpers: true do
  let(:school) { create(:school) }
  let(:chart_type) { :baseload }
  let(:params) { { school: school, chart_type: chart_type, html_class: 'usage-chart' } }

  context "with all params" do
    let(:html) { render_inline(ChartComponent.new(**params)) }

    it { expect(html).not_to have_selector("h4") }
    it { expect(html).not_to have_selector("h5") }
    it { expect(html).to have_selector("div", id: "chart_wrapper_baseload") }
    it { expect(html).to have_selector("div", class: "usage-chart") }

    it 'sets up chart config data attribute' do
      expect(html).to have_selector("div", id: 'chart_baseload') { |d| JSON.parse(d['data-chart-config'])['type'] == 'baseload' }
    end
  end

  context "with bad chart type" do
    let(:html) { render_inline(ChartComponent.new(school: school, chart_type: 'wibble')) }

    it 'shows an error message' do
      expect(html).to have_text("The chart can't be displayed")
    end
  end

  context "with title, subtitle, header and footer slots" do
    let(:html) do
      render_inline ChartComponent.new(**params) do |c|
        c.with_title    { "I'm a title" }
        c.with_subtitle { "I'm a subtitle" }
        c.with_header   { "<strong>I'm a header</strong>".html_safe }
        c.with_footer   { "<small>I'm a footer</small>".html_safe }
      end
    end
    it { expect(html).to have_selector("h4", text: "I'm a title") }
    it { expect(html).to have_selector("h4", id: "chart-section-baseload") }
    it { expect(html).to have_selector("h5", text: "I'm a subtitle") }
    it { expect(html).to have_selector("strong", text: "I'm a header") }
    it { expect(html).to have_selector("small", text: "I'm a footer") }
  end
end
