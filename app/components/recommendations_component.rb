# frozen_string_literal: true

class RecommendationsComponent < ViewComponent::Base
  attr_reader :title, :recommendations

  def initialize(title: nil, recommendations: [])
    @title = title
    @recommendations = recommendations
  end

  def render?
    recommendations.any?
  end
end
