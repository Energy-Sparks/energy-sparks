# frozen_string_literal: true

class RecommendationsComponent < ViewComponent::Base
  attr_reader :title, :recommendations, :limit, :max_lg

  def initialize(title: nil, recommendations: [], classes: '', limit: 4, max_lg: 3)
    @title = title
    @recommendations = recommendations.first(limit)
    @classes = classes
    @limit = limit
    @max_lg = max_lg
  end

  def classes
    " #{@classes}" if @classes
  end

  def responsive_classes(index)
    ' d-none d-xl-block' if index >= max_lg # limit to max_lg for screens less than XL
  end

  def default_image
    'placeholder300x200.png'
  end

  # this is for when we add activity key stages etc
  def footer
    false
  end

  def render?
    recommendations.any?
  end
end
