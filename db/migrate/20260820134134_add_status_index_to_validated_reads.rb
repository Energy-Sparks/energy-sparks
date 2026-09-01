# frozen_string_literal: true

class AddStatusIndexToValidatedReads < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!
  def up
    add_index :amr_validated_readings,
              %i[meter_id status],
              name: 'idx_amr_validated_reading_meter_status',
              algorithm: :concurrently
  end

  def down
    remove_index :amr_validated_readings,
                 name: 'idx_amr_validated_reading_meter_status',
                 algorithm: :concurrently
  end
end
