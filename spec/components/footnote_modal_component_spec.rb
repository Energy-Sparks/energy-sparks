# frozen_string_literal: true

require "rails_helper"

RSpec.describe FootnoteModalComponent, type: :component do
  let(:all_params) { { title: 'How did we calculate these figures?', modal_id: 'an_arbitrary_id' } }
  let(:params) { all_params }
  let(:body_content) { "<p>Some modal body content</p>" }

  context "with all params" do
    let(:html) do
      render_inline(FootnoteModalComponent.new(**params)) do |c|
        c.with_body_content { body_content }
      end
    end

    it "has the modal classes" do
      expect(html).to have_css('div.modal')
      expect(html).to have_css('div.modal-dialog')
      expect(html).to have_css('div.modal-content')
      expect(html).to have_css('div.modal-header')
      expect(html).to have_css('div.modal-body')
      expect(html).to have_css('div.modal-footer')
    end
  end

  context "with no body_content" do
    let(:html) do
      render_inline(FootnoteModalComponent.new(**params)) do |c|
      end
    end

    it { expect(html).to_not have_text(body_content) }
  end

  context "with body_content" do
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
end
