class RemoveMeterNoAndUseMpanMprn < ActiveRecord::Migration[5.2]
  def up
    ActiveRecord::Base.connection.execute(
      "UPDATE meters SET mpan_mprn = meter_no WHERE mpan_mprn IS NULL"
    )
    remove_column :meters, :meter_no
    add_index :meters, :mpan_mprn, unique: true
  end

  def down
    remove_index :meters, :mpan_mprn
    add_column :meters, :meter_no, :bigint
    ActiveRecord::Base.connection.execute(
      'UPDATE meters SET meter_no = mpan_mprn'
    )
  end
end
