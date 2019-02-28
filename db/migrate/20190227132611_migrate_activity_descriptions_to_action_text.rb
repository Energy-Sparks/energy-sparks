class MigrateActivityDescriptionsToActionText < ActiveRecord::Migration[6.0]
  def change
    execute <<-SQL
      INSERT INTO action_text_rich_texts(name, record_type, record_id, body, created_at, updated_at)
      SELECT 'description', 'Activity', id, description, created_at, updated_at
      FROM activities;
    SQL
  end
end
