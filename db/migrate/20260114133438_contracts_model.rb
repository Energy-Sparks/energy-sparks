class ContractsModel < ActiveRecord::Migration[7.2]
  def change
    create_table :commercial_products do |t|
      t.string :name, null: false, index: { unique: true }
      t.text :comments
      t.boolean :default, null: false, default: false

      t.float :small_school_price
      t.float :large_school_price
      t.integer :size_threshold
      t.float :mat_price
      t.float :private_account_fee
      t.float :metering_fee

      t.references :created_by, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }

      t.timestamps
    end

    create_enum :contract_status, %w[provisional confirmed]
    create_enum :contract_licence_period, %w[contract one_year]
    create_enum :contract_invoice_terms, %w[pro_rata full]

    create_table :commercial_contracts do |t|
      t.references :product, null: false, foreign_key: { to_table: :commercial_products }
      t.references :contract_holder, polymorphic: true, null: false

      t.string :name, null: false, index: { unique: true }
      t.text :comments
      t.enum :status, enum_type: :contract_status, null: false

      t.date :start_date, null: false
      t.date :end_date, null: false
      t.integer :number_of_schools, null: false
      t.enum :licence_period, enum_type: :contract_licence_period, null: false, default: 'contract'
      t.enum :invoice_terms, enum_type: :contract_invoice_terms, null: false, default: 'pro_rata'

      t.float :agreed_school_price

      t.references :created_by, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }

      t.timestamps
    end

    create_enum :licence_status, %w[provisional confirmed pending_invoice invoiced]

    create_table :commercial_licences do |t|
      t.references :contract, null: false, foreign_key: { to_table: :commercial_contracts }
      t.references :school, null: false

      t.enum :status, enum_type: :licence_status, null: false
      t.string :invoice_reference

      t.date :start_date, null: false
      t.date :end_date, null: false

      t.references :created_by, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }

      t.timestamps
    end

    create_enum :contract_contact_type, %w[procurement invoicing loa renewals]

    create_table :commercial_contract_contacts do |t|
      t.references :contract_holder, polymorphic: true, null: false
      t.references :user, null: true

      t.string :name, null: false
      t.string :email, null: false
      t.text :comments

      t.enum :contact_type, enum_type: :contract_contact_type, null: false

      t.references :created_by, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
