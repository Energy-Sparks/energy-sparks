module Alerts
  class GenerateFindOutMores
    def initialize(school)
      @school = school
    end

    def perform
      ActiveRecord::Base.transaction do
        calculation = FindOutMoreCalculation.create!(school: @school)
        @school.alerts.latest.each do |alert|
          process_find_out_mores(alert, calculation)
        end
      end
    end

  private

    def process_find_out_mores(alert, calculation)
      rating = alert.raw_rating
      return if rating.blank?
      alert_type_ratings = AlertTypeRating.for_rating(rating.to_f.round(1)).where(alert_type: alert.alert_type, find_out_more_active: true)
      alert_type_ratings.each do |alert_type_rating|
        content = alert_type_rating.current_content
        next if content.nil?
        calculation.find_out_mores.create!(alert: alert, content_version: content)
      end
    end
  end
end
