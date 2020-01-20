class MoveAttributeMeterTypesToArray < ActiveRecord::Migration[6.0]
  def change
    add_column :school_meter_attributes, :meter_types, :jsonb, default: []
    add_column :school_group_meter_attributes, :meter_types, :jsonb, default: []
    add_column :global_meter_attributes, :meter_types, :jsonb, default: []

    reversible do |dir|
      dir.up do
        connection.execute 'UPDATE school_meter_attributes SET meter_types = json_build_array(meter_type)'
        connection.execute 'UPDATE school_group_meter_attributes SET meter_types = json_build_array(meter_type)'
        connection.execute 'UPDATE global_meter_attributes SET meter_types = json_build_array(meter_type)'
      end
      dir.down do
        connection.execute 'UPDATE school_meter_attributes SET meter_type = meter_types->>0'
        connection.execute 'UPDATE school_group_meter_attributes SET meter_type = meter_types->>0'
        connection.execute 'UPDATE global_meter_attributes SET meter_type = meter_types->>0'
      end
    end

    remove_column :school_meter_attributes, :meter_type, :string
    remove_column :school_group_meter_attributes, :meter_type, :string
    remove_column :global_meter_attributes, :meter_type, :string
  end
end
