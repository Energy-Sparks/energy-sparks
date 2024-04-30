# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FootnoteModalComponent, type: :component do
  let(:all_params) { { title: 'How did we calculate these figures?', modal_id: 'an_arbitrary_id' } }
  let(:params) { all_params }
  let(:body_content) { '<p>Some modal body content</p>' }

  context 'with all params' do
    let(:html) do
      render_inline(FootnoteModalComponent.new(**params)) do |c|
        c.with_body_content { body_content }
      end
    end

    it 'has the modal classes' do
      expect(html).to have_css('div.modal')
      expect(html).to have_css('div.modal-dialog')
      expect(html).to have_css('div.modal-content')
      expect(html).to have_css('div.modal-header')
      expect(html).to have_css('div.modal-body')
      expect(html).to have_css('div.modal-footer')
    end
  end

  context 'with no body_content' do
    let(:html) do
      render_inline(FootnoteModalComponent.new(**params)) do |c|
      end
    end

    it { expect(html).not_to have_text(body_content) }
  end

  context 'with body_content' do
    let(:html) do
      # In a component .html.erb view the markup will be:
      # <a href="" data-toggle="modal" data-target="#table-footnotes">How did we calculate these figures? <span style="color: #007bff;"><%= fa_icon('question-circle') %></span></a>
      # <%= render(FootnoteModalComponent.new(title: "my title", modal_id: 'table-footnotes')) do |component| %>
      #   <% component.with_body_content do %>
      #     Some content
      #   <% end %>
      # <% end %>
      render_inline(FootnoteModalComponent.new(**params)) do |c|
        c.with_body_content { body_content }
      end
    end

    it { expect(html).to have_text(body_content) }
  end

  describe 'FootnoteModalComponent::Link', type: :component do
    shared_examples 'a footnote modal link' do |modal_id:, title:, remote:, href:, content:|
      it 'links to modal' do
        expect(html).to have_selector(
          'a' \
          "[title='#{title}']" \
          "[data-toggle='modal']" \
          "[data-target='##{modal_id}']" \
          "[data-remote='#{remote}']" \
          "[href='#{href}']" \
          )
        expect(html).to have_link(content)
      end
    end

    let(:link_params) { { modal_id: 'mymodal', href: 'http://href', remote: true, title: 'Another title', content: 'Link text' } }

    let(:html) do
      render_inline(FootnoteModalComponent::Link.new(**params.except(:content))) do
        params[:content]
      end
    end

    context 'with all params' do
      let(:params) { link_params }

      it_behaves_like 'a footnote modal link', title: 'Another title', remote: true, href: 'http://href', modal_id: 'mymodal', content: 'Link text'
    end

    context 'with default params' do
      let(:params) { link_params.except(:title, :remote, :title, :href) }

      it_behaves_like 'a footnote modal link', title: '', remote: false, href: '#', modal_id: 'mymodal', content: ''
    end
  end
end
