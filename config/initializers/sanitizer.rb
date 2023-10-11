# Rails::Html::Sanitizer is used when rendering ActionText but must allow tags and attributes for charts
#
# https://github.com/rails/rails/blob/5a7fa9a3b2cc25bb660e8074195216df6cd4226a/actiontext/app/helpers/action_text/content_helper.rb
#
# for defaults see
# Rails::Html::Sanitizer.safe_list_sanitizer.new.class.allowed_tags
# Rails::Html::Sanitizer.safe_list_sanitizer.new.class.allowed_attributes
#
Rails.application.configure do
  %w[button input radio label].each do |tag|
    config.action_view.sanitized_allowed_tags = Rails::Html::SafeListSanitizer.allowed_tags.add(tag)
  end

  %w[type for data-autoload-chart data-unit data-toggle data-placement data-original-title].each do |attr|
    config.action_view.sanitized_allowed_attributes = Rails::Html::SafeListSanitizer.allowed_attributes.add(attr)
  end
end
