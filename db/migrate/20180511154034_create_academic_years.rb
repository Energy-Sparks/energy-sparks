class CreateAcademicYears < ActiveRecord::Migration[5.1]
  def change
    create_table :academic_years do |t|
      t.date  :start_date
      t.date  :end_date
    end
  end
end
