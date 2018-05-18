class CreateAcademicYears < ActiveRecord::Migration[5.1]
  def change
    create_table :academic_years do |t|
      t.date  :start_year
      t.date  :end_year
    end
  end
end
