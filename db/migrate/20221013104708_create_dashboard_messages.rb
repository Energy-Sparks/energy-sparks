class CreateDashboardMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :dashboard_messages do |t|
      t.text :message
      t.timestamps
    end

    add_reference :school_groups, :dashboard_message, foreign_key: true
  end
end
