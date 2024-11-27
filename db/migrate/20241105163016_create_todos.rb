class CreateTodos < ActiveRecord::Migration[7.1]
  def change
    # was todos
    create_table :todos do |t|
      ### programme_type, audit
      # t.references :tasklist_source, polymorphic: true, null: false, index: true
      t.references :assignable, polymorphic: true, null: false, index: true

      # activity_type, intervention_type
      # t.references :task_source, polymorphic: true, null: false, index: true
      t.references :task, polymorphic: true, null: false, index: true

      t.integer :position, default: 0, null: false
      t.text :notes
      t.timestamps
    end

    # was tasklist_completed_tasks
    create_table :completed_todos do |t|
      # t.references :todo, null: false, index: true
      t.references :todo, null: false, index: true

      # programme, audit
      # t.references :tasklist_target, polymorphic: true, null: false, index: true
      t.references :completable, polymorphic: true, null: false, index: true

      # activity, observation
      # t.references :task_target, polymorphic: true, null: false, index: true
      t.references :recording, polymorphic: true, null: false, index: true
      t.timestamps
    end
  end
end
