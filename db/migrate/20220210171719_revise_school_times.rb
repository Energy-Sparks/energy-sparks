class ReviseSchoolTimes < ActiveRecord::Migration[6.0]
  def change
    add_column :school_times, :usage_type, :integer, default: 0, null: false
    add_column :school_times, :calendar_period, :integer, default: 0, null: false
  end
end
