class AddActivationDateToSchool < ActiveRecord::Migration[6.0]
  def change
    add_column :schools, :activation_date, :date
  end
end
