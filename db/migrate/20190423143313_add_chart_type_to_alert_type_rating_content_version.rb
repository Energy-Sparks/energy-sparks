class AddChartTypeToAlertTypeRatingContentVersion < ActiveRecord::Migration[5.2]
  def change
    add_column :alert_type_rating_content_versions, :chart_type, :text, default: "none"
  end
end
