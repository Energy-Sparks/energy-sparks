# frozen_string_literal: true
require "rails_helper"
include ActionView::Helpers::UrlHelper

RSpec.describe NoticeComponent, type: :component, include_application_helper: true do
  let(:all_params) { { status: :neutral, classes: 'extra-classes' } }
  let(:params) { all_params }
  let(:content) { "<p>Content</p>" }
  let(:link) { link_to 'Link text', 'href' }

  context "with all params" do
    let(:html) do
      render_inline(NoticeComponent.new(**params)) do |c|
        c.with_link { link }
        content
      end
    end
    it "has the status class" do
      expect(html).to have_css('div.page-notice.neutral')
    end
    it "has additional classes" do
      expect(html).to have_css('div.page-notice.extra-classes')
    end
    it { expect(html).to have_link("Link text", href: 'href') }
    it { expect(html).to have_text(content) }

    context "with unrecognised status" do
      let(:params) { all_params.update(status: :unrecognised) }
      it { expect { html }.to raise_error(ArgumentError, 'Status must be: positive, negative or neutral') }
    end

    context "with recognised statuses" do
      [:positive, :negative, :neutral].each do |status|
        let(:params) { all_params.update(status: status) }
        it "should recognise #{status}" do
          expect { html }.to_not raise_error
        end
      end
    end
  end

  context "with no link" do
    let(:html) do
      render_inline(NoticeComponent.new(**params)) do |c|
        content
      end
    end
    it { expect(html).to have_text(content) }
    it { expect(html).to_not have_link("Link text", href: 'href') }
  end

  context "with no content" do
    let(:html) do
      render_inline(NoticeComponent.new(**params)) do |c|
        c.with_link { link }
      end
    end
    it { expect(html.to_html).to be_blank }
  end
end
