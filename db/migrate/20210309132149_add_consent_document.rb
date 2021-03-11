class AddConsentDocument < ActiveRecord::Migration[6.0]
  def change
    create_table :consent_documents do |t|
      t.belongs_to :school, index: true
      t.text :title, null: false
      t.timestamps
    end
  end
end
