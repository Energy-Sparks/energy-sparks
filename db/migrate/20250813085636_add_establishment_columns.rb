class AddEstablishmentColumns < ActiveRecord::Migration[7.2]
  def self.get_columns_to_add
    return {
    establishment_type_group_code: :integer,
    open_date: :datetime,
    close_date: :datetime,
    phase_of_education_code: :integer,
    statutory_low_age: :integer,
    statutory_high_age: :integer,
    boarders_code: :integer,
    nursery_provision_name: :string,
    official_sixth_form_code: :integer,
    diocese_code: :string,
    school_capacity: :integer,
    census_date: :datetime,
    trusts_code: :integer,
    federations_code: :integer,
    ukprn: :integer,
    street: :string,
    locality: :string,
    address3: :string,
    town: :string,
    county_name: :string,
    gor_code: :string,
    district_administrative_code: :string,
    administrative_ward_code: :string,
    parliamentary_constituency_code: :string,
    urban_rural_code: :string,
    gssla_code_name: :string,
    easting: :integer,
    northing: :integer,
    previous_la_code: :integer,
    msoa_code: :string,
    lsoa_code: :string,
    fsm: :integer
  }
  end

  def up
    change_table(:lists_establishments, bulk: true) do |t|
      cols = AddEstablishmentColumns.get_columns_to_add
      cols.each_key do |col|
        t.column(col, cols[col])
      end
    end
  end

  def down
    change_table(:lists_establishments, bulk: true) do |t|
      AddEstablishmentColumns.get_columns_to_add.each_key do |col|
        t.remove(col)
      end
    end
  end
end
