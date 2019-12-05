class AddNewSourceTypeRemoveAccessType < ActiveRecord::Migration[6.0]
  def change
    add_column :amr_data_feed_configs, :source_type, :integer, default: 0, null: false

    execute <<-SQL
      UPDATE amr_data_feed_configs SET source_type = 0 WHERE access_type = 'Email';
      UPDATE amr_data_feed_configs SET source_type = 1 WHERE access_type = 'Manual';
      UPDATE amr_data_feed_configs SET source_type = 2 WHERE access_type = 'API';
      UPDATE amr_data_feed_configs SET source_type = 3 WHERE access_type = 'SFTP';
    SQL

    remove_column :amr_data_feed_configs, :access_type, :text
  end
end

