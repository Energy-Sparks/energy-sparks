class AddTranslatedAlertTypeRatingContentVersionEmailTitle < ActiveRecord::Migration[6.0]
  def change
    AlertTypeRatingContentVersion.all.each do |alert_type_rating_content_version|
      alert_type_rating_content_version.update(email_title_en: alert_type_rating_content_version[:email_title])
    end
  end
end
