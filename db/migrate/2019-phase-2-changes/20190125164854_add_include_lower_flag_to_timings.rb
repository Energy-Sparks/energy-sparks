class AddIncludeLowerFlagToTimings < ActiveRecord::Migration[5.2]
  def change
    add_column :activity_timings, :include_lower, :boolean, default: false
  end
end
