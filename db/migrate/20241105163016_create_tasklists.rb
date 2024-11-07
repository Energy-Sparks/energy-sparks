class CreateTasklists < ActiveRecord::Migration[7.1]
  def change
    create_table :tasklist_tasks do |t|
      t.references :tasklist_source, polymorphic: true, null: false, index: true
      t.references :task_source, polymorphic: true, null: false, index: true
      t.integer :position, default: 0, null: false
      t.text :notes
      t.timestamps
    end

    create_table :tasklist_completed_tasks do |t|
      t.references :tasklist_target, polymorphic: true, null: false, index: true
      t.references :tasklist_task, null: false, index: true
      t.timestamps
    end

# more long winded version (less polymorphism)

=begin
    create_table :tasklist_activity_types do |t|
      t.references :tasklist_source, polymorphic: true, null: false, index: true
      t.references :activity_type, polymorphic: true, null: false, index: true
      t.integer :position, default: 0, null: false
      t.text :notes
      t.timestamps
    end

    create_table :tasklist_intervention_types do |t|
      t.references :tasklist_source, polymorphic: true, null: false, index: true
      t.references :activity_type, polymorphic: true, null: false, index: true
      t.integer :position, default: 0, null: false
      t.text :notes
      t.timestamps
    end

    create_table :tasklist_completed_activity_types do |t|
      t.references :tasklist_target, polymorphic: true, null: false, index: true
      t.references :tasklist_activity_type, null: false, index: true
      t.timestamps
    end

    create_table :tasklist_completed_intervention_types do |t|
      t.references :tasklist_target, polymorphic: true, null: false, index: true
      t.references :tasklist_intervention_type, null: false, index: true
      t.timestamps
    end
=end

  end
end
