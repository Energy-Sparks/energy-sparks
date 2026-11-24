# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::HeaderNavComponent, type: :component do
  it 'renders a small button by default' do
    render_inline(described_class.new) do |header_nav|
      header_nav.with_header title: 'Title'
      header_nav.with_button 'Link', '/'
    end

    expect(page).to have_css('a.btn.btn-secondary.btn-sm', text: 'Link')
  end

  it 'allows the button size to be overridden' do
    render_inline(described_class.new) do |header_nav|
      header_nav.with_header title: 'Title'
      header_nav.with_button 'Link', '/', size: nil
    end

    expect(page).to have_css('a.btn.btn-secondary', text: 'Link')
    expect(page).to have_no_css('a.btn-sm')
  end

  it 'renders a dropdown with its items' do
    render_inline(described_class.new) do |header_nav|
      header_nav.with_header title: 'Title'
      header_nav.with_dropdown title: 'Jump to', items: [['One', '#one'], ['Two', '#two']]
    end

    expect(page).to have_css('div.dropdown.d-inline-block')
    expect(page).to have_css('a.dropdown-toggle.btn.btn-outline-primary', text: 'Jump to')
    expect(page).to have_link('One', href: '#one')
    expect(page).to have_link('Two', href: '#two')
  end

  it 'accepts any custom action component' do
    component = Elements::ButtonComponent.new('Custom', '/custom')

    render_inline(described_class.new) do |header_nav|
      header_nav.with_header title: 'Title'
      header_nav.with_action(component)
    end

    expect(page).to have_link('Custom', href: '/custom')
  end

  it 'renders multiple buttons and dropdowns in the order they are added' do
    render_inline(described_class.new) do |header_nav|
      header_nav.with_header title: 'Title'
      header_nav.with_button 'First', '/first'
      header_nav.with_dropdown title: 'First menu', items: [['One', '#one']]
      header_nav.with_dropdown title: 'Second menu', items: [['Two', '#two']]
      header_nav.with_button 'Last', '/last'
    end

    expect(page.all('a.btn, button.btn').map(&:text)).to eq(['First', 'First menu', 'Second menu', 'Last'])
  end
end
