class AddExtraIndexesAndForeignKeys < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :alerts, :schools, on_delete: :cascade
    add_foreign_key :alerts, :alert_types, on_delete: :cascade
    add_index :alerts, :run_on
    add_index :alerts, [:alert_type_id, :created_at]

    reversible do |dir|
      dir.up do
        remove_foreign_key :school_times, :schools
        remove_foreign_key :contacts, :schools
        remove_foreign_key :users, :schools
        add_foreign_key :school_times, :schools, on_delete: :cascade
        add_foreign_key :contacts, :schools, on_delete: :cascade
        add_foreign_key :users, :schools, on_delete: :cascade
      end
      dir.down do
        remove_foreign_key :school_times, :schools
        remove_foreign_key :contacts, :schools
        remove_foreign_key :users, :schools
        add_foreign_key :school_times, :schools
        add_foreign_key :contacts, :schools
        add_foreign_key :users, :schools
      end
    end
  end
end
