# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InfoBarComponent, type: :component do
  let(:title)         { 'This is an info bar' }
  let(:button_title)  { 'Click me' }
  let(:button_link)   { 'http://www.example.com' }
  let(:icon)          { '<i class="fas fa-school fa-3x"></i>' }
  let(:status)        { :neutral }
  let(:params)        do
    {
      icon: icon.html_safe,
      title: title,
      buttons: { button_title => button_link }
    }
  end

  let(:component) { InfoBarComponent.new(**params) }

  let(:html) do
    render_inline(component)
  end

  it 'renders a notice' do
    expect(html).to have_css('.notice-component')
  end

  it 'renders the right status' do
    expect(html).to have_css('.neutral')
  end

  it 'centers the items in the row' do
    expect(html).to have_css('.row.align-items-center')
  end

  it 'centers the icon in the column' do
    expect(html).to have_css('.col-md-1.justify-content-center')
  end

  it 'right aligns the button link' do
    expect(html).to have_css('.col-md-3.justify-content-end')
  end

  it 'includes icon' do
    within('.row .col-md-1') do
      expect(html).to have_css('.fa-school')
    end
  end

  it 'includes the title' do
    within('.row .col-md-8') do
      expect(html).to have_content(title)
    end
  end

  it 'includes the link' do
    within('.row .col-md-3') do
      expect(html).to have_link(button_title, href: button_link)
    end
  end
end
