class AddUrnColumnToSchool < ActiveRecord::Migration[5.0]
  def change
    add_column :schools, :urn, :integer
    add_index :schools, :urn, unique: true
    # give existing schools a dummy urn
    School.all.each do |school|
      school.update_attribute(:urn, 99_999 - school.id) unless school.urn
    end
    # now make urn not_null
    change_column :schools, :urn, :integer, null: false
  end
end
