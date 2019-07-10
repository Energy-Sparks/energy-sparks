class CreateProgrammeTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :programme_types do |t|
      t.text    :title
      t.text    :description
      t.boolean :active, default: false
    end
  end
end
