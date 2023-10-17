# frozen_string_literal: true

require "rails_helper"

RSpec.describe RecommendationsComponent, type: :component, include_url_helpers: true do
  let(:image) { { io: File.open(Rails.root.join('spec', 'fixtures', 'images', 'sheffield.png')), filename: 'sheffield.png', content_type: 'image/png' } }
  let(:activity_types) { 6.times.collect { create(:activity_type) } }
  let(:all_params) { { recommendations: activity_types, title: 'Title text', classes: 'my-class', id: 'my-id', limit: 5, max_lg: 4 } }
  let(:cards) { html.css("div.card") }
  let(:title) { html.css("h4 strong") }
  let(:items) { [] }

  let(:html) do
    render_inline(RecommendationsComponent.new(**params)) do |c|
      c.with_items(items) if items.any?
    end
  end

  context "with all params" do
    let(:params) { all_params }

    it { expect(html).to have_selector("h4 strong", text: "Title text") }

    it "adds specified classes" do
      expect(html).to have_css('div.recommendations-component.my-class')
    end

    it "adds specified id" do
      expect(html).to have_css('div.recommendations-component#my-id')
    end

    it "shows 'limit' amount of cards" do
      expect(cards.count).to eq(5)
    end

    it "has recommendation content" do
      cards.each_with_index do |card, i|
        expect(card).to have_link(activity_types[i].name, href: polymorphic_path(activity_types[i]))
        within('a') do
          expect(card.to_s).to include('placeholder300x200')
        end
        expect(card.css('.card-text')).to have_link(activity_types[i].name, href: polymorphic_path(activity_types[i]))
      end
    end

    it "has image" do
      activity_types[0].image_en.attach(**image)
      expect(cards[0].to_s).to include('sheffield.png')
    end

    it "has default image" do
      expect(cards[0].to_s).to include('placeholder300x200')
    end

    it "adds responsive clasess" do
      cards[0..3].each do |card|
        expect(card).not_to have_css('.d-none.d-xl-block')
      end
      expect(cards[4]).to have_css('.d-none.d-xl-block')
    end
  end

  context "with defaults" do
    let(:params) { all_params.except(:title, :classes, :id, :limit, :max_lg) }

    it "does not display title" do
      expect(html).not_to have_selector("h4 strong")
    end

    it "does not add css" do
      expect(html).not_to have_css('div.recommendations-component.my-class')
    end

    it "does not add id" do
      expect(html).not_to have_css('div.recommendations-component#my-id')
    end

    it "limits to 4" do
      expect(cards.count).to eq(4)
    end

    it "sets max_lg to 3" do
      cards[0..2].each do |card|
        expect(card).not_to have_css('.d-none.d-xl-block')
      end
      expect(cards[3]).to have_css('.d-none.d-xl-block')
    end
  end

  context "with no items" do
    let(:items) { [] }
    let(:params) { all_params.except(:recommendations) }

    it "doesn't render" do
      expect(html.to_s).to be_blank
    end
  end

  context "with items" do
    let(:items) do
      [{ name: 'Name 1', href: 'my_url', image: 'recommendations/get-energised.png' },
       { name: 'Name 2', href: 'my_other_url' }]
    end
    let(:params) { all_params.except(:recommendations) }

    context "card with image" do
      let(:item) { cards[0].to_s }

      it "has image" do
        expect(item).to include('get-energised')
      end

      it "has text and link" do
        expect(item).to have_link('Name 1', href: 'my_url')
      end
    end

    context "card without image" do
      let(:item) { cards[1].to_s }

      it "has default image" do
        expect(item).to include('placeholder300x200')
      end

      it "has text and link" do
        expect(item).to have_link('Name 2', href: 'my_other_url')
      end
    end
  end
end
