class CreateTodos < ActiveRecord::Migration[7.1]
  def change
    create_table :todos do |t|
      t.references :assignable, polymorphic: true, null: false, index: true
      t.references :task, polymorphic: true, null: false, index: true
      t.integer :position, default: 0, null: false
      t.text :notes
      t.timestamps
    end

    create_table :completed_todos do |t|
      t.references :todo, null: false, index: true
      t.references :completable, polymorphic: true, null: false, index: true
      t.references :recording, polymorphic: true, null: false, index: true
      t.timestamps
    end
  end
end
