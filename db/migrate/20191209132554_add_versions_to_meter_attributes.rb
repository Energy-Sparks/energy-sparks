class AddVersionsToMeterAttributes < ActiveRecord::Migration[6.0]
  def change
    add_column :meter_attributes, :replaced_by_id, :bigint
    add_column :school_meter_attributes, :replaced_by_id, :bigint
    add_column :school_group_meter_attributes, :replaced_by_id, :bigint

    add_column :meter_attributes, :deleted_by_id, :bigint
    add_column :school_meter_attributes, :deleted_by_id, :bigint
    add_column :school_group_meter_attributes, :deleted_by_id, :bigint

    add_column :meter_attributes, :created_by_id, :bigint
    add_column :school_meter_attributes, :created_by_id, :bigint
    add_column :school_group_meter_attributes, :created_by_id, :bigint


    add_foreign_key :meter_attributes, :meter_attributes, column: :replaced_by_id, on_delete: :nullify
    add_foreign_key :school_meter_attributes, :school_meter_attributes, column: :replaced_by_id, on_delete: :nullify
    add_foreign_key :school_group_meter_attributes, :school_group_meter_attributes, column: :replaced_by_id, on_delete: :nullify

    add_foreign_key :meter_attributes, :users, column: :deleted_by_id, on_delete: :nullify
    add_foreign_key :school_meter_attributes, :users, column: :deleted_by_id, on_delete: :nullify
    add_foreign_key :school_group_meter_attributes, :users, column: :deleted_by_id, on_delete: :nullify

    add_foreign_key :meter_attributes, :users, column: :created_by_id, on_delete: :nullify
    add_foreign_key :school_meter_attributes, :users, column: :created_by_id, on_delete: :nullify
    add_foreign_key :school_group_meter_attributes, :users, column: :created_by_id, on_delete: :nullify
  end
end
