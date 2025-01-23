# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InfoBarComponent, type: :component do
  let(:title)         { 'This is an info bar' }
  let(:button_title)  { 'Click me' }
  let(:button_link)   { 'http://www.example.com' }
  let(:icon)          { '<i class="fas fa-school fa-3x"></i>' }
  let(:status)        { :positive }
  let(:all_params) do
    {
      icon: icon.html_safe,
      title: title,
      buttons: { button_title => button_link },
      classes: 'extra-classes',
      style: :compact,
      status: status
    }
  end

  let(:params) { all_params }

  let(:component) { InfoBarComponent.new(**params) }

  let(:html) do
    render_inline(component)
  end

  it 'renders a notice' do
    expect(html).to have_css('.notice-component')
  end

  it 'renders the right status' do
    expect(html).to have_css('.positive')
  end

  it 'centers the items in the row' do
    expect(html).to have_css('.row.align-items-center')
  end

  it 'centers the icon in the column' do
    expect(html).to have_css('.col-md-1.justify-content-center')
  end

  it 'right aligns the button link' do
    expect(html).to have_css('.col-md-2.justify-content-end')
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
    within('.row .col-md-2') do
      expect(html).to have_link(button_title, href: button_link)
    end
  end

  it 'has additional classes' do
    expect(html).to have_css('div.notice-component.extra-classes')
  end

  context 'with :style' do
    context 'when :style is :normal' do
      let(:params) { all_params.merge({ style: :normal })}

      it 'adds normal classes' do
        expect(html).to have_css('div.notice-component.p-4.mb-4')
      end
    end

    context 'when :style is :compact' do
      let(:params) { all_params.merge({ style: :compact })}

      it 'adds compact classes' do
        expect(html).to have_css('div.notice-component.p-3.mb-3')
      end
    end

    context 'when :style is not provided' do
      let(:params) { all_params.except(:style) }

      it 'adds normal classes' do
        expect(html).to have_css('div.notice-component.p-4.mb-4')
      end
    end
  end

  context 'without icon and button' do
    let(:params) { all_params.except(:icon, :buttons) }

    it 'content has full width' do
      expect(html).to have_css('div.col-md-12')
    end
  end

  context 'without icon but with button' do
    let(:params) { all_params.except(:icon) }

    it 'content is 10 cols wide' do
      expect(html).to have_css('div.col-md-10')
    end
  end

  context 'without button but with icon' do
    let(:params) { all_params.except(:buttons) }

    it 'content is 11 cols wide' do
      expect(html).to have_css('div.col-md-11')
    end
  end

  context 'with icon_cols greater than 1' do
    let(:params) { all_params.except(:buttons).merge({ icon_cols: 2 }) }

    it 'icon is 2 cols wide' do
      expect(html).to have_css('div.col-md-2')
    end

    it 'content is 10 cols wide' do
      expect(html).to have_css('div.col-md-10')
    end
  end
end
