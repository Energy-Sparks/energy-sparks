# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PromptListComponent, type: :component, include_application_helper: true do
  let(:all_params) { { id: id, classes: classes } }
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:params) { all_params }
  let(:title) { 'Title' }
  let(:prompt_text) { 'Prompt text' }
  let(:pill) { ActionController::Base.helpers.content_tag(:span, 'Warning', class: 'badge badge-warning')}
  let(:link) { ActionController::Base.helpers.link_to 'Link text', 'href' }

  context 'with all params' do
    let(:html) do
      render_inline(described_class.new(**params)) do |c|
        c.with_title { title }
        c.with_link { link }
        c.with_prompt id: 'prompt-id' do
          prompt_text
        end
      end
    end

    it_behaves_like 'an application component' do
      let(:expected_classes) { classes }
      let(:expected_id) { id }
    end

    it { expect(html).to have_text(title) }
    it { expect(html).to have_link('Link text', href: 'href') }

    it 'includes prompt' do
      within('#prompt-id') do
        expect(html).to have_text(prompt_text)
      end
    end
  end

  context 'with no prompts it does not render' do
    let(:component) do
      described_class.new(**params) do |c|
        c.with_title { title }
        c.with_link { link }
      end
    end

    it { expect(component.render?).to eq(false) }
  end

  context 'with no link' do
    let(:html) do
      render_inline(described_class.new(**params)) do |c|
        c.with_title { title }
        c.with_prompt id: 'prompt-id' do
          'Prompt text'
        end
      end
    end

    it { expect(html).to have_text(title) }
    it { expect(html).not_to have_link('Link text', href: 'href') }
  end

  context 'with no title' do
    let(:html) do
      render_inline(described_class.new(**params)) do |c|
        c.with_link { link }
        c.with_prompt id: 'prompt-id' do
          'Prompt text'
        end
      end
    end

    it { expect(html).to have_link('Link text', href: 'href') }
    it { expect(html).not_to have_text(title) }
  end
end
