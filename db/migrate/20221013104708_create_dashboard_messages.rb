class CreateDashboardMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :dashboard_messages do |t|
      t.text :message
      t.references :messageable, polymorphic: true, index: { unique: true }
      t.timestamps
    end
  end
end
