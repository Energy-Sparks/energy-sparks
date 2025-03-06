# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PromptComponent, :include_application_helper, type: :component do
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:params) { { id: id, status: :neutral, icon: icon, classes: classes, fuel_type: :gas, always_render: always_render } }
  let(:content) { '<p>Content</p>' }
  let(:title) { 'Title' }
  let(:icon) { 'calendar' }
  let(:pill) { ActionController::Base.helpers.content_tag(:span, 'Warning', class: 'badge badge-warning')}
  let(:link) { ActionController::Base.helpers.link_to 'Link text', 'href' }
  let(:always_render) { false }

  shared_examples 'it displays all content' do
    it { expect(html).to have_text(title) }
    it { expect(html).to have_text('Warning') }

    it { expect(html).to have_link('Link text', href: 'href') }
    it { expect(html).to have_text(content) }

    let(:icon_html) { html.css('span.fa-stack') }

    it 'has the icon' do
      expect(html).to have_css('span.fa-stack')
      expect(icon_html).to have_css('i.fa-circle')
      expect(icon_html).to have_css("i.fa-#{icon}")
    end
  end

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

    it_behaves_like 'it displays all content'

    it_behaves_like 'an application component' do
      let(:expected_classes) { classes }
      let(:expected_id) { id }
    end

    context 'with unrecognised status' do
      let(:params) { { id: id, status: :unrecognised, icon: icon, classes: classes } }

      it { expect { html }.to raise_error(ArgumentError, 'Status must be: none, positive, negative or neutral') }
    end

    context 'with no status' do
      let(:params) { { id: id, status: nil, icon: icon, classes: classes } }

      it_behaves_like 'it displays all content'

      it_behaves_like 'an application component' do
        let(:expected_classes) { classes }
        let(:expected_id) { id }
      end
    end

    context 'with fuel type' do
      let(:icon) { :bolt }
      let(:params) { { id: id, status: :neutral, fuel_type: :electricity } }

      it_behaves_like 'it displays all content'
    end

    context 'with icon and fuel type' do
      let(:icon) { :calendar }
      let(:params) { { id: id, status: :neutral, icon: 'calendar', fuel_type: :electricity } }

      it_behaves_like 'it displays all content'
    end

    context 'with recognised statuses' do
      [:none, :positive, :negative, :neutral].each do |status|
        let(:params) { { id: id, status: status, icon: icon, classes: classes } }
        it "recognises #{status}" do
          expect { html }.not_to raise_error
        end
      end
    end
  end

  context 'with compact style' do
    let(:params) { { id: id, status: :neutral, icon: icon, classes: classes, style: :compact } }
    let(:html) do
      render_inline(described_class.new(**params)) do |c|
        c.with_link { link }
        c.with_title { title }
        c.with_pill { pill }
        content
      end
    end

    it_behaves_like 'it displays all content'

    it_behaves_like 'an application component' do
      let(:expected_classes) { classes }
      let(:expected_id) { id }
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

    context 'when always_render is set to true' do
      let(:always_render) { true }

      it { expect(html).to have_link('Link text', href: 'href') }
    end
  end
end
