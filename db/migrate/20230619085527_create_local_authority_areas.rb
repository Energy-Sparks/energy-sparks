class CreateLocalAuthorityAreas < ActiveRecord::Migration[6.0]
  def change
    create_table :local_authority_areas do |t|
      t.string :code
      t.string :name

      t.timestamps
    end
  end
end
