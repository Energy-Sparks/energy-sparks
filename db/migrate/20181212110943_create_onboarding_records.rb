class CreateOnboardingRecords < ActiveRecord::Migration[5.2]
  def change
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")

    create_table :school_onboardings do |t|
      t.uuid :uuid, null: false, default: 'gen_random_uuid()'
      t.string :school_name, null: false
      t.string :contact_email, null: false
      t.text :notes
      t.references :school,                   foreign_key: {on_delete: :cascade}
      t.references :created_user,             foreign_key: {on_delete: :nullify, to_table: :users}
      t.references :school_group,             foreign_key: {on_delete: :restrict}
      t.references :weather_underground_area, foreign_key: {on_delete: :restrict, to_table: :areas}
      t.references :solar_pv_tuos_area,       foreign_key: {on_delete: :restrict, to_table: :areas}
      t.references :calendar_area,            foreign_key: {on_delete: :restrict, to_table: :areas}
      t.timestamps
    end

    create_table :school_onboarding_events do |t|
      t.references :school_onboarding, null: false, foreign_key: {on_delete: :cascade}
      t.integer :event, null: false
      t.timestamps
    end

  end
end
