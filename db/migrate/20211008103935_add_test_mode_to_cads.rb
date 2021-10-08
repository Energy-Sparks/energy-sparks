class AddTestModeToCads < ActiveRecord::Migration[6.0]
  def change
    add_column :cads, :test_mode, :boolean, default: false
    add_column :cads, :max_power, :integer, default: 1000
    add_column :cads, :refresh_interval, :integer, default: 3000
    add_column :cads, :last_reading, :float, default: 0
    add_column :cads, :last_read_at, :timestamp
  end
end
