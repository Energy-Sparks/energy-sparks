class CreateTestimonials < ActiveRecord::Migration[7.2]
  def change
    create_table :testimonials do |t|
      t.string :name
      t.string :organisation
      t.boolean :active, default: false, null: false
      t.integer :category, default: 0, null: false
      t.references :case_study, null: true
      t.timestamps
    end
  end
end
