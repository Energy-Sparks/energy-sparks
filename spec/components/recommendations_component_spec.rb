# frozen_string_literal: true

require "rails_helper"

RSpec.describe RecommendationsComponent, type: :component, include_url_helpers: true do

  let(:html) { render_inline(RecommendationsComponent.new(**params)) }
  let(:activity_types) { 6.times.collect { create(:activity_type) } }
  let(:all_params) { { recommendations: activity_types, title: 'Title text', classes: 'my-class', limit: 4, max_lg: 3 } }
  let(:cards) { html.css("div.card") }
  let(:title) { html.css("h4 strong") }

  context "with all params" do
    let(:params) { all_params }
    it { expect(html).to have_selector("h4 strong", text: "Title text") }
    it "adds classes" do
      expect(html).to have_css('div.card-deck.recommendations.my-class')
    end
    it "shows 'limit' cards" do
      expect(cards.count).to eq(4)
    end

    it "has recommendation content" do
      cards.each_with_index do |card, i|
        expect(card.to_s).to include('placeholder300x200')
        expect(card.css('.card-text')).to have_link(activity_types[i].name, href: polymorphic_path(activity_types[i]))
      end
    end
  end

  context "with defaults" do
    let(:params) { all_params.except(:title, :classes, :limit, :max_lg) }
  end

  context "with no recommendations" do
    it "doesn't render" do
    end
  end

end
