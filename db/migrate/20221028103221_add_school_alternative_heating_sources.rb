class AddSchoolAlternativeHeatingSources < ActiveRecord::Migration[6.0]
  def up
    create_table :school_alternative_heating_sources do |t|
      t.references :school, foreign_key: true
      t.text :notes
      t.numeric :percent_of_overall_use
      t.integer :alternative_heating_source
    end
  end

  def down
    drop_table :school_alternative_heating_sources
  end
end
