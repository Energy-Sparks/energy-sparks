class AddTranslatedAlertTypeRatingContentVersionSmsContent < ActiveRecord::Migration[6.0]
  def change
    AlertTypeRatingContentVersion.all.each do |alert_type_rating_content_version|
      alert_type_rating_content_version.update(sms_content_en: alert_type_rating_content_version[:sms_content])
    end
  end
end
