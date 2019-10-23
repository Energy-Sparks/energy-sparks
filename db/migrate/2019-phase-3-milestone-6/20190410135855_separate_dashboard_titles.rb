class SeparateDashboardTitles < ActiveRecord::Migration[5.2]
  def change
    add_column :find_out_more_type_content_versions, :pupil_dashboard_title, :string
    reversible do |dir|
      dir.up do
        connection.execute('UPDATE find_out_more_type_content_versions SET pupil_dashboard_title = dashboard_title')
      end
    end
    change_column_null :find_out_more_type_content_versions, :pupil_dashboard_title, false
    rename_column :find_out_more_type_content_versions, :dashboard_title, :teacher_dashboard_title
  end
end
