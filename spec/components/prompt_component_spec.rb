# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PromptComponent, :include_application_helper, type: :component do
  let(:all_params) { { id: id, status: :neutral, icon: icon, classes: classes } }
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:params) { all_params }
  let(:content) { '<p>Content</p>' }
  let(:title) { 'Title' }
  let(:icon) { 'bolt' }
  let(:pill) { ActionController::Base.helpers.content_tag(:span, 'Warning', class: 'badge badge-warning')}
  let(:link) { ActionController::Base.helpers.link_to 'Link text', 'href' }

  context 'with all params' do
    let(:html) do
      render_inline(described_class.new(**params)) do |c|
        c.with_link { link }
        c.with_title { title }
        c.with_pill { pill }
        content
      end
    end

    it 'has the status class' do
      expect(html).to have_css('div.prompt-component.neutral')
    end

    it_behaves_like 'an application component' do
      let(:expected_classes) { classes }
      let(:expected_id) { id }
    end

    it { expect(html).to have_text(title) }
    it { expect(html).to have_text('Warning') }

    it { expect(html).to have_link('Link text', href: 'href') }
    it { expect(html).to have_text(content) }

    it 'has the icon' do
      expect(html).to have_css('span.fa-stack')
      within('span.fa-stack') do
        expect(html).to have_css('i.fa-circle')
        expect(html).to have_css("i.fa-#{icon}")
      end
    end

    context 'with unrecognised status' do
      let(:params) { all_params.update(status: :unrecognised) }

      it { expect { html }.to raise_error(ArgumentError, 'Status must be: none, positive, negative or neutral') }
    end

    context 'with recognised statuses' do
      [:positive, :negative, :neutral].each do |status|
        let(:params) { all_params.update(status: status) }
        it "recognises #{status}" do
          expect { html }.not_to raise_error
        end
      end
    end
  end

  context 'with no link' do
    let(:html) do
      render_inline(described_class.new(**params)) do |_c|
        content
      end
    end

    it { expect(html).to have_text(content) }
    it { expect(html).not_to have_link('Link text', href: 'href') }
  end

  context 'with no content' do
    let(:html) do
      render_inline(described_class.new(**params)) do |c|
        c.with_link { link }
      end
    end

    it { expect(html.to_html).to be_blank }
  end
end
