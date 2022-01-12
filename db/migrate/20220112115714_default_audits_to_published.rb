class DefaultAuditsToPublished < ActiveRecord::Migration[6.0]
  def change
    change_column_default :audits, :published, true
  end
end
