class CreateProgrammeActivities < ActiveRecord::Migration[6.0]
  def change
    create_join_table :programmes, :activity_type, table_name: :programme_activities do |t|
      t.references  :activity
      t.index [:programme_id, :activity_type_id], unique: true, name: 'programme_activity_type_uniq'
      t.primary_key :id
      t.integer     :position, default: 0, null: false
    end
  end
end