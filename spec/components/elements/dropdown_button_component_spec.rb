# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::DropdownButtonComponent, :include_application_helper, type: :component do
  let(:name) { 'Actions' }
  let(:items) { [['Edit', '/edit'], ['Delete', '/delete']] }
  let(:params) { {} }

  let(:html) { render_inline(described_class.new(name, items, **params)) }

  it { expect(html).to have_css('div.dropdown') }
  it { expect(html).to have_link(name, href: '#') }
  it { expect(html).to have_css('a.dropdown-toggle.btn.btn-secondary', text: name) }
  it { expect(html).to have_link('Edit', href: '/edit') }
  it { expect(html).to have_link('Delete', href: '/delete') }

  it 'links the menu to the toggle' do
    id = html.at_css('a.dropdown-toggle')[:id]
    expect(html).to have_css("div.dropdown-menu[aria-labelledby='#{id}']")
  end

  context 'with outline primary style' do
    let(:params) { { style: :primary, outline: true } }

    it { expect(html).to have_css('a.dropdown-toggle.btn.btn-outline-primary', text: name) }
  end

  context 'with size' do
    let(:params) { { size: :sm } }

    it { expect(html).to have_css('a.dropdown-toggle.btn.btn-secondary.btn-sm', text: name) }
  end

  context 'with a custom id' do
    let(:params) { { id: 'custom-dropdown' } }

    it { expect(html).to have_link(name, id: 'custom-dropdown') }
  end

  context 'with additional classes' do
    let(:params) { { classes: 'd-inline-block me-2' } }

    it { expect(html).to have_css('div.dropdown.d-inline-block.me-2') }
  end

  context 'with an unknown style' do
    let(:params) { { style: :notgood } }

    it { expect { html }.to raise_error(ArgumentError, 'Unknown button style') }
  end

  context 'with an unknown size' do
    let(:params) { { size: :notgood } }

    it { expect { html }.to raise_error(ArgumentError, 'Unknown button size') }
  end
end
