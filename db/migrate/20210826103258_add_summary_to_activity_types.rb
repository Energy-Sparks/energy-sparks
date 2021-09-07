class AddSummaryToActivityTypes < ActiveRecord::Migration[6.0]
  def change
    add_column :activity_types, :summary, :string
  end
end
