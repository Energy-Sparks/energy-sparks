class ChangeDataEnabledDefaultOnSchools < ActiveRecord::Migration[6.0]
  def change
    change_column_default :schools, :data_enabled, from: true, to: false
  end
end
