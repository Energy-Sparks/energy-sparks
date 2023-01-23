# frozen_string_literal: true

class RecommendationsComponent < ViewComponent::Base
  attr_reader :name, :recommendations

  def initialize(name:, recommendations: [])
    @name = name
    @recommendations = recommendations
  end

  class ImageComponent < ViewComponent::Base
    attr_reader :recommendation

    def initialize(recommendation, classes: '')
      @recommendation = recommendation
      @classes = classes
    end

    def classes
      css_classes = 'card-img-top img-fluid'
      css_classes += " #{@classes}" if @classes
      css_classes
    end

    def image
      if I18n.locale.to_s == 'cy' && activity_type.t_attached(:image, :cy).present?
        recommendation.image_cy
      elsif recommendation.t_attached(:image, :en).present?
         recommendation.image_en
      else
        "placeholder300x200.png"
      end
    end

    def call
      image_tag image, class: classes
    end
  end
end
