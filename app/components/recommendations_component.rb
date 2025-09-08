# frozen_string_literal: true

class RecommendationsComponent < ApplicationComponent
  attr_reader :title, :description, :limit, :limit_lg

  renders_many :items, 'ItemComponent'

  def initialize(title: nil, description: nil, recommendations: [], limit: 4, limit_lg: 3, **_kwargs)
    super
    @title = title
    @description = description
    @limit = limit
    @limit_lg = limit_lg
    @recommendations = recommendations
  end

  # `#helpers` can't be used during initialization as it depends on the view context that only exists once a ViewComponent is passed to the Rails render pipeline.
  def before_render
    @recommendations.each do |recommendation|
      with_item(name: recommendation.name, href: helpers.url_for(recommendation), image: recommendation.t_attached_or_default(:image))
    end
  end

  def responsive_classes(index)
    ' d-none d-xl-block' if index >= limit_lg # limit to limit_lg for screens less than XL
  end

  # this is for when we add activity key stages etc
  def footer
    false
  end

  def render?
    items.any?
  end

  class ItemComponent < ViewComponent::Base
    attr_accessor :name, :href

    def initialize(name: nil, href: nil, image: nil)
      @name = name
      @href = href
      @image = image
    end

    def image
      @image || self.class.default_image
    end

    def self.default_image
      'placeholder300x200.png'
    end
  end
end
