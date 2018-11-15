class CreateSchoolTimes < ActiveRecord::Migration[5.2]
  def change
    create_table :school_times do |t|
      t.references  :school, foreign_key: true
      t.integer     :opening_time, default: 850
      t.integer     :closing_time, default: 1520
      t.integer     :day
    end
  end
end
