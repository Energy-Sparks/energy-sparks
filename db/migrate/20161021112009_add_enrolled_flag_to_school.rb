class AddEnrolledFlagToSchool < ActiveRecord::Migration[5.0]
  def change
    add_column :schools, :enrolled, :boolean, default: false
  end
end
