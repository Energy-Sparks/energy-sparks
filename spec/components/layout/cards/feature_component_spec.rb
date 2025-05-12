# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Layout::Cards::FeatureComponent, :include_application_helper, type: :component do
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:theme) { :dark }
  let(:base_params) { { id: id, classes: classes, theme: theme } }
  let(:date) { Time.zone.today }

  let(:html) do
    render_inline(described_class.new(**params)) do |card|
      card.with_tag('Guidance')
      card.with_tag('Fuel')
      card.with_date(date)
      card.with_author(href: '/') {'Happy Blogger'}
      card.with_header(title: 'Header')
      card.with_description { 'Description' }
      card.with_button('button 1', 'link_to_button_1', style: :primary)
      card.with_button('button 2', 'link_to_button_2', style: :secondary)
      card.with_link(href: '/') { 'Read more' }
    end
  end

  context 'with base params' do
    let(:params) { base_params }

    it_behaves_like 'an application component' do
      let(:expected_classes) { classes }
      let(:expected_id) { id }
    end

    it_behaves_like 'a layout component' do
      let(:expected_theme) { theme }
    end

    it { expect(html).to have_css('h3') }
    it { expect(html).to have_content('Guidance') }
    it { expect(html).to have_content('Fuel') }
    it { expect(html).to have_content(short_dates(date)) }
    it { expect(html).to have_link('Happy Blogger', href: '/') }
    it { expect(html).to have_content('Header') }
    it { expect(html).to have_content('Description') }
    it { expect(html).to have_link('button 1', href: 'link_to_button_1') }
    it { expect(html).to have_link('button 2', href: 'link_to_button_2') }
  end

  context 'with size params' do
    context 'when not specified' do
      let(:params) { base_params }

      it { expect(html).to have_css('h3') }
    end

    described_class.sizes.each do |size, value|
      context "when size = #{size}" do
        let(:params) { base_params.merge(size: size) }

        it { expect(html).to have_css("h#{value}") }
      end
    end
  end
end
