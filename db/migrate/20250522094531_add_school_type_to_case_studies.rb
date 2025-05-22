class AddSchoolTypeToCaseStudies < ActiveRecord::Migration[7.2]
  def change
    add_column :case_studies, :school_type, :integer, null: true # enum
  end
end
