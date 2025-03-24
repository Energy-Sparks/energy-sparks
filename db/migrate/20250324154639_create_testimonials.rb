class CreateTestimonials < ActiveRecord::Migration[7.2]
  def change
    create_table :testimonials do |t|
      t.string :title
      t.text :quote
      t.string :name
      t.string :role
      t.string :location
      t.references :case_study, null: true

      t.timestamps
    end
  end
end
