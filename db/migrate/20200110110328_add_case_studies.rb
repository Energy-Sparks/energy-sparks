class AddCaseStudies < ActiveRecord::Migration[6.0]
  def change
    create_table :case_studies do |t|
      t.string :title, null: false
      t.integer :position, null: false, default: 0
      t.timestamps
    end
  end
end
