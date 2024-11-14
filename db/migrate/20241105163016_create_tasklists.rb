class CreateTasklists < ActiveRecord::Migration[7.1]
  def change
    create_table :tasklist_tasks do |t|
      t.references :tasklist_template, polymorphic: true, null: false, index: true
      t.references :task_template, polymorphic: true, null: false, index: true
      t.integer :position, default: 0, null: false
      t.text :notes
      t.timestamps
    end

    create_table :tasklist_completed_tasks do |t|
      t.references :tasklist_task, null: false, index: true
      t.references :tasklist_instance, polymorphic: true, null: false, index: true
      t.references :task_instance, polymorphic: true, null: false, index: true
      t.datetime :happened_on
      t.timestamps
    end


## tasklist_template
## tasklist_instance

## task_template
## task_instance

# more long winded version (less polymorphism)

=begin
    create_table :tasklist_activity_types do |t|
      t.references :tasklist_template, polymorphic: true, null: false, index: true
      t.references :activity_type, polymorphic: true, null: false, index: true
      t.integer :position, default: 0, null: false
      t.text :notes
      t.timestamps
    end

    create_table :tasklist_intervention_types do |t|
      t.references :tasklist_template, polymorphic: true, null: false, index: true
      t.references :intervention_type, polymorphic: true, null: false, index: true
      t.integer :position, default: 0, null: false
      t.text :notes
      t.timestamps
    end

    create_table :tasklist_completed_activity_types do |t|
      t.references :tasklist_instance, polymorphic: true, null: false, index: true
      t.references :activity, null: false, index: true
      t.references :activity_type, null: false, index: true
      t.timestamps
    end

    create_table :tasklist_completed_intervention_types do |t|
      t.references :tasklist_instance, polymorphic: true, null: false, index: true
      t.references :observation, null: false, index: true
      t.references :intervention_type, null: false, index: true
      t.timestamps
    end
=end

  end
end
