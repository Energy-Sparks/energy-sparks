module Alerts
  class FetchContent
    def initialize(alert)
      @alert = alert
    end

    def content_versions(scope:, today: Time.zone.today)
      rating = @alert.rating
      return [] if rating.blank?

      alert_type_ratings = AlertTypeRating.
        for_rating(rating.to_f.round(1)).
        where(alert_type: @alert.alert_type).
        where(:"#{scope}_active" => true)

      current_content = alert_type_ratings.map(&:current_content).compact
      current_content.select {|content| content.meets_timings?(scope: scope, today: today)}
    end

    def content_versions_with_priority(scope:, today: Time.zone.today)
      content_versions(scope: scope, today: today).map do |content_version|
        [content_version, calculate_score(content_version, scope)]
      end
    end

    def self.apply_weighting(rating, weighting, time_of_year_relevance)
      ((11 - rating) * weighting * time_of_year_relevance) / 1000
    end

    private

    def calculate_score(content_version, scope)
      self.class.apply_weighting(@alert.rating,
                                 content_version.read_attribute(:"#{scope}_weighting"),
                                 @alert.priority_data.fetch('time_of_year_relevance') {5.0})
    end
  end
end
