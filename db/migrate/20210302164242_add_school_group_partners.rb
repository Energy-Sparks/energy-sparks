class AddSchoolGroupPartners < ActiveRecord::Migration[6.0]
  def change
    create_table :school_group_partners do |t|
      t.belongs_to :school_group, index: true
      t.belongs_to :partner, index: true
      t.integer :position
      t.timestamps
    end
  end
end
