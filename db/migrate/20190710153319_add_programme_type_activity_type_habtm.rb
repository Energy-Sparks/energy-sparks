class AddProgrammeTypeActivityTypeHabtm < ActiveRecord::Migration[6.0]
  def change
    create_join_table :programme_types, :activity_types, table_name: :programme_type_activity_types do |t|
      t.index [:programme_type_id, :activity_type_id], unique: true, name: 'programme_type_activity_type_uniq'
      t.primary_key :id
      t.integer     :position, default: 0, null: false
    end
  end
end

