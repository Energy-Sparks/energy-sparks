module Alerts
  class FetchContent
    def initialize(alert)
      @alert = alert
    end

    def content_versions(scope = {})
      rating = @alert.raw_rating
      return [] if rating.blank?
      alert_type_ratings = AlertTypeRating.for_rating(rating.to_f.round(1)).where(scope.merge(alert_type: @alert.alert_type))
      alert_type_ratings.map(&:current_content).compact
    end
  end
end
