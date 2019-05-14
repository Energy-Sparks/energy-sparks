class BetterNamedFindOutMoreFields < ActiveRecord::Migration[6.0]
  def change
    rename_column :alert_type_rating_content_versions, :page_title, :find_out_more_title
    rename_column :alert_type_rating_content_versions, :page_content, :find_out_more_content
    rename_column :alert_type_rating_content_versions, :chart_title, :find_out_more_chart_title
    rename_column :alert_type_rating_content_versions, :chart_variable, :find_out_more_chart_variable
  end
end
