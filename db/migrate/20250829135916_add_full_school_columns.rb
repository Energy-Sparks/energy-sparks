class AddFullSchoolColumns < ActiveRecord::Migration[7.2]
  def change
    add_column :schools,             :full_school, :boolean, default: true
    add_column :school_onboardings,  :full_school, :boolean, default: true
  end
end
