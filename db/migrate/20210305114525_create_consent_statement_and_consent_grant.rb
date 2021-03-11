class CreateConsentStatementAndConsentGrant < ActiveRecord::Migration[6.0]
  def change
    create_table :consent_statements do |t|
      t.text :title, null: false
      t.boolean :current, default: false
      t.timestamps
    end
    create_table :consent_grants do |t|
      t.references :consent_statement, foreign_key: true, null: false
      t.references :user, foreign_key: true, null: false
      t.references :school, foreign_key: true, null: false
      t.text :name
      t.text :job_title
      t.text :school_name
      t.text :ip_address
      t.text :guid
      t.timestamps
    end
  end
end
