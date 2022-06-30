class AllowNullTitleOnCaseStudy < ActiveRecord::Migration[6.0]
  def change
    change_column_null :case_studies, :title, true
  end
end
