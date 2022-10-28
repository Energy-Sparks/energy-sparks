class AddSchoolAlternativeHeatingSources < ActiveRecord::Migration[6.0]
  def up
    create_table :alternative_heating_sources do |t|
      t.references :school, foreign_key: true
      t.integer :source
      t.numeric :percent_of_overall_use
      t.text :notes
    end
  end

  def down
    drop_table :alternative_heating_sources
  end
end
