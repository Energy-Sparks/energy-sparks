class ReviseSchoolTimes < ActiveRecord::Migration[6.0]
  def change
    add_column :school_times, :usage_type, :integer, default: 0, null: false
    add_column :school_times, :term_time_only, :boolean, default: true, null: false
  end
end
