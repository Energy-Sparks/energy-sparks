class AddTestModeToCads < ActiveRecord::Migration[6.0]
  def change
    add_column :cads, :test_mode, :boolean, default: false
    add_column :cads, :max_power, :integer
  end
end
