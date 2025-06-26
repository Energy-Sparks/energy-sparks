# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TabsComponent, type: :component do
  def render_component(**kwargs)
    render_inline(described_class.new(**kwargs)) do |component|
      component.with_tab(name: :first, label: 'First') { 'first tab content' }
      component.with_tab(name: :second, label: 'Second') { 'second tab content' }
    end
  end

  def expect_tab(tab, name, label, active)
    expect(tab.attributes.transform_values(&:value).symbolize_keys).to eq(
      { 'aria-controls': name,
        'aria-selected': active.to_s,
        'data-toggle': 'tab',
        class: ['nav-link', active ? 'active' : nil].compact.join(' '),
        href: "##{name}",
        id: "#{name}-tab",
        role: 'tab' }
    )
    expect(tab.text).to eq(label)
  end

  def expect_tab_content(div, name, active, content, top_margin)
    expect(div.attributes.transform_values(&:value).symbolize_keys).to eq(
      { id: name,
        class: (%w[tab-pane fade] + (active ? %w[show active] : [])).join(' '),
        role: 'tabpanel',
        'aria-labelledby': "#{name}-tab" }
    )
    if top_margin
      expect(div).to have_css('div.mt-3', exact_text: content)
    else
      expect(div.text.strip).to eq(content)
    end
  end

  def expect_correct_html(html, top_margin)
    tabs = html.css('li.nav-item a.nav-link')
    expect(tabs.size).to eq(2)
    expect_tab(tabs[0], 'first', 'First', true)
    expect_tab(tabs[1], 'second', 'Second', false)

    content_divs = html.css('.tab-content > div')
    expect(content_divs.size).to eq(2)
    expect_tab_content(content_divs[0], 'first', true, 'first tab content', top_margin)
    expect_tab_content(content_divs[1], 'second', false, 'second tab content', top_margin)
  end

  it 'has the right html' do
    expect_correct_html(render_component, true)
  end

  it 'has the right html with no top margin' do
    expect_correct_html(render_component(top_margin: false), false)
  end
end
