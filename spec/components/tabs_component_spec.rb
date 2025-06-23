# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TabsComponent, :include_url_helpers, type: :component do
  def component_html(**kwargs)
    render_inline(described_class.new(**kwargs)) do |component|
      component.with_tab(name: :first, label: 'First') { 'first tab content' }
      component.with_tab(name: :second, label: 'Second') { 'second tab content' }
    end
  end

  def normalize_html(html)
    html = Nokogiri::HTML5.fragment(html) if html.is_a?(String)
    html.traverse do |node|
      if node.text.strip.empty?
        node.remove
      else
        node.content = node.text.strip
      end
    end
  end

  let(:expected_html) do
    <<~HTML
      <ul class="here nav nav-tabs url-aware tabs-component" role="tablist">
        <li class="nav-item">
          <a id="first-tab" aria-controls="first" data-toggle="tab" role="tab" aria-selected="true"
            class="nav-link active" href="#first">First</a>
        </li>
        <li class="nav-item">
          <a id="second-tab" aria-controls="second" data-toggle="tab" role="tab" aria-selected="false" class="nav-link"
            href="#second">Second</a>
        </li>
      </ul>
      <div class="tab-content">
        <div id="first" aria-labelledby="first-tab" role="tabpanel" class="tab-pane fade show active">
          <div class="mt-3">first tab content</div>
        </div>
        <div id="second" aria-labelledby="second-tab" role="tabpanel" class="tab-pane fade">
          <div class="mt-3">second tab content</div>
        </div>
      </div>
    HTML
  end

  it 'has the right html' do
    expect(normalize_html(component_html)).to eq(normalize_html(expected_html))
  end

  it 'has the right html with no top margin' do
    html = render_inline(described_class.new(top_margin: false)) do |component|
      component.with_tab(name: :first, label: 'First') { 'first tab content' }
      component.with_tab(name: :second, label: 'Second') { 'second tab content' }
    end
    expected = Nokogiri::HTML5.fragment(component_html(top_margin: false))
    expected.css('.mt-3').each { |node| node.replace(node.children) }
    expect(normalize_html(html)).to eq(normalize_html(expected))
  end
end
