module Alerts
  class GenerateFindOutMores
    def initialize(school)
      @school = school
    end

    def perform
      @school.alerts.latest.each do |alert|
        process_find_out_mores(alert)
      end
    end

  private

    def process_find_out_mores(alert)
      rating = alert.raw_rating
      return if rating.blank?
      find_out_more_types = FindOutMoreType.for_rating(rating).where(alert_type: alert.alert_type)
      find_out_more_types.each do |find_out_more_type|
        content = find_out_more_type.current_content
        next if content.nil?
        FindOutMore.create!(alert: alert, content_version: content)
      end
    end
  end
end
