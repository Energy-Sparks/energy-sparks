module Alerts
  class FetchContent
    def initialize(alert)
      @alert = alert
    end

    def content_versions(scope:, today: Time.zone.today)
      rating = @alert.raw_rating
      return [] if rating.blank?

      alert_type_ratings = AlertTypeRating.
        for_rating(rating.to_f.round(1)).
        where(alert_type: @alert.alert_type).
        where(:"#{scope}_active" => true)

      current_content = alert_type_ratings.map(&:current_content).compact
      current_content.select {|content| content.meets_timings?(scope: scope, today: today)}
    end
  end
end
