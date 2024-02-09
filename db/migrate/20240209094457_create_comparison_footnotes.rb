class CreateComparisonFootnotes < ActiveRecord::Migration[6.1]
  def change
    create_table :comparison_footnotes do |t|
      t.string :key, null: false, index: { unique: true }
      t.timestamps
    end
  end
end
