class AddSchoolAlternativeHeatingSources < ActiveRecord::Migration[6.0]
  def up
    create_table :school_alternative_heating_sources do |t|
      t.references :school, foreign_key: true
      t.text :notes
      t.numeric :percent_of_overall_use
    end
    execute(<<-SQL)
      CREATE TYPE alternative_heating_source_types AS ENUM ('oil', 'propane_gas', 'biomass_boiler', 'district_heating');
    SQL
    add_column(:school_alternative_heating_sources, :alternative_heating_source_type, :alternative_heating_source_types)
  end

  def down
    remove_column(:school_alternative_heating_sources, :alternative_heating_source_type)
    execute(<<-SQL)
      DROP TYPE alternative_heating_source_types;
    SQL
    drop_table
  end
end
