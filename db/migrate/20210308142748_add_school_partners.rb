class AddSchoolPartners < ActiveRecord::Migration[6.0]
  def change
    create_table :school_partners do |t|
      t.belongs_to :school, index: true
      t.belongs_to :partner, index: true
      t.integer :position
      t.timestamps
    end
  end
end
