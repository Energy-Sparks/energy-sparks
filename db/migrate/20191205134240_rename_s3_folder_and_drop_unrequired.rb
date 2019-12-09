class RenameS3FolderAndDropUnrequired < ActiveRecord::Migration[6.0]
  def change
    rename_column :amr_data_feed_configs, :s3_folder, :identifier
    remove_column :amr_data_feed_configs, :s3_archive_folder, :text
    remove_column :amr_data_feed_configs, :local_bucket_path, :text
  end
end
