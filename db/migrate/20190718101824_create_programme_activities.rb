class CreateProgrammeActivities < ActiveRecord::Migration[6.0]
  def change
    create_join_table :programmes, :activities, table_name: :programme_activities do |t|
      t.references  :activity_type
      t.index [:programme_id, :activity_id], unique: true, name: 'programme_activity_uniq'
      t.primary_key :id
      t.integer     :position, default: 0, null: false
    end
  end
end
