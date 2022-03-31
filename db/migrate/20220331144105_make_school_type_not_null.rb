class MakeSchoolTypeNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :schools, :school_type, false
  end
end
