class AddNewSourceTypeRemoveAccessType < ActiveRecord::Migration[6.0]
  def change
    add_column :amr_data_feed_configs, :source_type, :integer, default: 0, null: false

    AmrDataFeedConfig.all.each do |config|
      config.update(source_type: config.access_type.downcase.to_sym)
    end

    remove_column :amr_data_feed_configs, :access_type, :text
  end
end
